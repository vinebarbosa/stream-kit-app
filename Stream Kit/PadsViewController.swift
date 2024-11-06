//
//  PadsViewController.swift
//  Stream Kit
//
//  Created by Vinícios Barbosa on 22/10/24.
//

import UIKit
import Network

class PadsViewController: UIViewController {
    private var webSocketManager: WebSocketManager?
    private var pads: [Pad] = []
    private var socketUrl: String = UserDefaults.standard.string(forKey: "socketUrl") ?? ""

    lazy var padsCollectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.itemSize = CGSize(width: 100, height: 100)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PadsCollectionCellView.self, forCellWithReuseIdentifier: PadsCollectionCellView.identifier)
        collectionView.backgroundColor = UIColor(named: "background")

        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setHierarchy()
        setConstraints()
        
        verifyLocalNetworkPermission()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webSocketManager?.disconnect()
    }

    private func setupView() {
        view.backgroundColor = .backgroundSecondary
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setHierarchy() {
        view.addSubview(padsCollectionView)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            padsCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            padsCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            padsCollectionView.heightAnchor.constraint(equalToConstant: 580),
            padsCollectionView.widthAnchor.constraint(equalToConstant: 340),
        ])
    }

    private func setupWebSocket(url: String) {
        self.webSocketManager = WebSocketManager(url: url, onDataReceived: updateCollectionView)
        self.webSocketManager?.connect()
        self.webSocketManager?.sendMessage("GET_DATA")
    }

    private func updateCollectionView(with pads: [Pad]) {
        self.pads = pads
        DispatchQueue.main.async { [weak self] in
            self?.padsCollectionView.reloadData()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.updateConstraints(for: size)
        }, completion: nil)
    }

    private func updateConstraints(for size: CGSize) {
        
        NSLayoutConstraint.deactivate(padsCollectionView.constraints)
        
        let isLandscape = size.width > size.height
        let width: CGFloat = isLandscape ? 580 : 340
        let height: CGFloat = isLandscape ? 340 : 580
        
        NSLayoutConstraint.activate([
            padsCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            padsCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            padsCollectionView.heightAnchor.constraint(equalToConstant: height),
            padsCollectionView.widthAnchor.constraint(equalToConstant: width),
        ])
        
        view.layoutIfNeeded()
    }
        

    @objc func appDidBecomeActive() {
        webSocketManager?.connect()
        webSocketManager?.sendMessage("GET_DATA")
    }

    private func onPadTapped(id: Int) {
        webSocketManager?.sendMessage(String(id))
    }
    
    private func verifyLocalNetworkPermission() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                // Caso possuir a permissão de acesso a rede local
                DispatchQueue.main.async {
                    self.setupWebSocket(url: self.socketUrl)
                }
            } else {
                // Caso não possuir a permissão de acesso a rede local, pedir ao usuário
                self.requestLocalNetworkPermission()
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    private func requestLocalNetworkPermission() {
        // Essa é uma chamada de rede local que força o prompt de permissão para o usuário.
        // Use uma conexão "dummy" para forçar a solicitação de permissão.
        let dummyConnection = NWConnection(host: "localhost", port: 12345, using: .udp)
        dummyConnection.start(queue: .main)
        
        // Quando o usuário conceder a permissão, configurar o WebSocket
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Delay para permitir resposta do prompt
            dummyConnection.cancel()
            self.setupWebSocket(url: self.socketUrl)
        }
    }
}

extension PadsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PadsCollectionCellView.identifier, for: indexPath) as! PadsCollectionCellView

        if pads.count > 0 {
            let pad = pads[indexPath.item]
            cell.configure(with: pad, onTap: onPadTapped)
        }

        return cell
    }
}
