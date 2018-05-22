//
//  Zap
//
//  Created by Otto Suess on 24.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class SettingsViewController: GroupedTableViewController {
    init() {
        let sections: [Section<SettingsItem>] = [
            Section(title: "scene.settings.title".localized, rows: [
                CurrencySelectionSettingsItem(),
                BitcoinUnitSelectionSettingsItem(),
                OnChainRequestAddressTypeSelectionSettingsItem()
            ]),
            Section(title: "scene.settings.section.security".localized, rows: [
                ConnectRemoteNodeSettingsItem(),
                RemoveRemoteNodeSettingsItem(),
                UpdatePinSettingsItem(),
                TouchIDSettingItem(),
                PaperKeySettingsItem()
            ]),
            Section(title: "scene.settings.section.wallet".localized, rows: [
                LockWalletSettingsItem()
            ])
        ]
        
        super.init(sections: sections)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
