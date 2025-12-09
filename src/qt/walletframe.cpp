#include "createwalletdialog.h"
...
void WalletFrame::showCreateWalletDialog()
{
    CreateWalletDialog dlg;
    if (dlg.exec() == QDialog::Accepted && dlg.isConfirmed()) {
        // ...create/init new wallet using dlg.getSeedWords()...
        QMessageBox::information(this, tr("Wallet created"), tr("Your wallet has been created and is ready to use."));
        // Insert actual wallet logic as needed.
    }
}
...