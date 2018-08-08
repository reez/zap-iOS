//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Lightning
import UIKit

extension UIStoryboard {
    static func instantiateChannelListViewController(
        channelListViewModel: ChannelListViewModel,
        closeButtonTapped: @escaping (Channel, String, @escaping () -> Void) -> Void,
        addChannelButtonTapped: @escaping () -> Void,
        transactionDetailButtonTapped: @escaping (String) -> Void) -> UIViewController {
        let viewController = Storyboard.channelList.initial(viewController: ChannelListViewController.self)
        
        viewController.channelListViewModel = channelListViewModel
        viewController.closeButtonTapped = closeButtonTapped
        viewController.addChannelButtonTapped = addChannelButtonTapped
        viewController.transactionDetailButtonTapped = transactionDetailButtonTapped
        
        viewController.tabBarItem.title = "Channels"
        viewController.tabBarItem.image = UIImage(named: "tabbar_wallet", in: Bundle.library, compatibleWith: nil)
        
        return viewController
    }
}

final class ChannelListViewController: UIViewController {
    @IBOutlet private weak var backgroundGradientView: GradientView! {
        didSet {
            backgroundGradientView.direction = .vertical
            backgroundGradientView.gradient = [UIColor.zap.backgroundGradientTop, UIColor.zap.backgroundGradientBottom]
        }
    }
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private var headerView: UICollectionReusableView!
    
    fileprivate var channelListViewModel: ChannelListViewModel?
    
    fileprivate var addChannelButtonTapped: (() -> Void)?
    fileprivate var closeButtonTapped: ((Channel, String, @escaping () -> Void) -> Void)?
    fileprivate var transactionDetailButtonTapped: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Channels"
        
        collectionView.registerCell(ChannelCell.self)
        collectionView.register(UINib(nibName: HeaderCollectionReusableView.kind, bundle: Bundle.library), forSupplementaryViewOfKind: HeaderCollectionReusableView.kind, withReuseIdentifier: HeaderCollectionReusableView.kind)

        view.addBackgroundGradient()
        
        channelListViewModel?.dataSource.observeNext { [weak self] _ in
            self?.collectionView.reloadData()
        }.dispose(in: reactive.bag)
        
        collectionView.dataSource = self
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        channelListViewModel?.refresh()
        sender.endRefreshing()
    }
    
    @IBAction private func presentAddChannel(_ sender: Any) {
        addChannelButtonTapped?()
    }
    
    func closeChannel(for channelViewModel: ChannelViewModel) {
        closeButtonTapped?(channelViewModel.channel, channelViewModel.name.value) { [weak self] in
            self?.channelListViewModel?.close(channelViewModel.channel) { result in
                if let error = result.error {
                    self?.parent?.presentErrorToast(error.localizedDescription)
                } else {
                    self?.parent?.presentSuccessToast("scene.channels.close_success.toast".localized)
                }
            }
        }
    }
}

extension ChannelListViewController: ChannelListHeaderDelegate {
    func openChannelButtonTapped() {
        addChannelButtonTapped?()
    }
}

extension ChannelListViewController: ChannelListDataSource {
    func heightForItem(at index: Int) -> CGFloat {
        return channelListViewModel?.dataSource[index].detailViewModel.elements.height ?? 100
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channelListViewModel?.dataSource.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let channelCell: ChannelCell = collectionView.dequeueCellForIndexPath(indexPath)
        channelCell.channelViewModel = channelListViewModel?.dataSource[indexPath.item]
        channelCell.delegate = self
        return channelCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.kind, for: indexPath)
        if let view = view as? HeaderCollectionReusableView {
            view.delegate = self
        }
        return view
    }
}

extension ChannelListViewController: ChannelCellDelegate {
    func closeChannelButtonTapped(channelViewModel: ChannelViewModel) {
        closeButtonTapped?(channelViewModel.channel, channelViewModel.name.value) { [weak self] in
            self?.channelListViewModel?.close(channelViewModel.channel) { result in
                print(result)
            }
        }
    }
    
    func fundingTransactionTxIdButtonTapped(channelViewModel: ChannelViewModel) {
        transactionDetailButtonTapped?(channelViewModel.channel.channelPoint.fundingTxid)
    }
}
