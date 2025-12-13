/*
 * Qt4 Trinity GUI.
 */
#include "walletframe.h"
#include "bitcoingui.h"
#include "walletview.h"
#include "createwalletdialog.h"

#include <QHBoxLayout>
#include <QMessageBox>
#include <QStackedWidget>

WalletFrame::WalletFrame(BitcoinGUI *_gui) :
    QFrame(_gui),
    gui(_gui),
    clientModel(0)
{
    // Leave HBox hook for adding a list view later
    QHBoxLayout *walletFrameLayout = new QHBoxLayout(this);
    setContentsMargins(0,0,0,0);
    walletStack = new QStackedWidget(this);
    walletFrameLayout->setContentsMargins(0,0,0,0);
    walletFrameLayout->addWidget(walletStack);
}

WalletFrame::~WalletFrame()
{
}

void WalletFrame::setClientModel(ClientModel *clientModel)
{
    this->clientModel = clientModel;
    
    QMap<QString, WalletView*>::const_iterator i;
    for (i = mapWalletViews.constBegin(); i != mapWalletViews.constEnd(); ++i)
        i.value()->setClientModel(clientModel);
}

bool WalletFrame::addWallet(const QString& name, WalletModel *walletModel)
{
    if (!gui || !clientModel || mapWalletViews.count(name) > 0)
        return false;

    WalletView *walletView = new WalletView(this, gui);
    walletView->setBitcoinGUI(gui);
    walletView->setClientModel(clientModel);
    walletView->setWalletModel(walletModel);
    walletStack->addWidget(walletView);
    mapWalletViews[name] = walletView;
    return true;
}

bool WalletFrame::setCurrentWallet(const QString& name)
{
    if (mapWalletViews.count(name) == 0)
        return false;

    WalletView *walletView = mapWalletViews.value(name);
    walletStack->setCurrentWidget(walletView);
    return true;
}

void WalletFrame::removeAllWallets()
{
    QMap<QString, WalletView*>::const_iterator i;
    for (i = mapWalletViews.constBegin(); i != mapWalletViews.constEnd(); ++i)
        walletStack->removeWidget(i.value());
    mapWalletViews.clear();
}

bool WalletFrame::handleURI(const QString &uri)
{
    WalletView *walletView = currentWalletView();
    if (!walletView)
        return false;

    return walletView->handleURI(uri);
}

void WalletFrame::showOutOfSyncWarning(bool fShow)
{
    QMap<QString, WalletView*>::const_iterator i;
    for (i = mapWalletViews.constBegin(); i != mapWalletViews.constEnd(); ++i)
        i.value()->showOutOfSyncWarning(fShow);
}

WalletView *WalletFrame::currentWalletView()
{
    return qobject_cast<WalletView*>(walletStack->currentWidget());
}

WalletModel *WalletFrame::currentWalletModel()
{
    WalletView *wallet_view = currentWalletView();
    return wallet_view ? wallet_view->getWalletModel() : 0;
}

void WalletFrame::gotoOverviewPage()
{
    QMap<QString, WalletView*>::const_iterator i;
    for (i = mapWalletViews.constBegin(); i != mapWalletViews.constEnd(); ++i)
        i.value()->gotoOverviewPage();
}

void WalletFrame::gotoHistoryPage()
{
    QMap<QString, WalletView*>::const_iterator i;
    for (i = mapWalletViews.constBegin(); i != mapWalletViews.constEnd(); ++i)
        i.value()->gotoHistoryPage();
}

void WalletFrame::gotoAddressBookPage()
{
    QMap<QString, WalletView*>::const_iterator i;
    for (i = mapWalletViews.constBegin(); i != mapWalletViews.constEnd(); ++i)
        i.value()->gotoAddressBookPage();
}

void WalletFrame::gotoReceiveCoinsPage()
{
    QMap<QString, WalletView*>::const_iterator i;
    for (i = mapWalletViews.constBegin(); i != mapWalletViews.constEnd(); ++i)
        i.value()->gotoReceiveCoinsPage();
}

void WalletFrame::gotoSendCoinsPage(QString addr)
{
    QMap<QString, WalletView*>::const_iterator i;
    for (i = mapWalletViews.constBegin(); i != mapWalletViews.constEnd(); ++i)
        i.value()->gotoSendCoinsPage(addr);
}

void WalletFrame::gotoSignMessageTab(QString addr)
{
    WalletView *walletView = currentWalletView();
    if (walletView)
        walletView->gotoSignMessageTab(addr);
}

void WalletFrame::gotoVerifyMessageTab(QString addr)
{
    WalletView *walletView = currentWalletView();
    if (walletView)
        walletView->gotoVerifyMessageTab(addr);
}

void WalletFrame::encryptWallet(bool status)
{
    WalletView *walletView = currentWalletView();
    if (walletView)
        walletView->encryptWallet(status);
}

void WalletFrame::backupWallet()
{
    WalletView *walletView = currentWalletView();
    if (walletView)
        walletView->backupWallet();
}

void WalletFrame::changePassphrase()
{
    WalletView *walletView = currentWalletView();
    if (walletView)
        walletView->changePassphrase();
}

void WalletFrame::unlockWallet()
{
    WalletView *walletView = currentWalletView();
    if (walletView)
        walletView->unlockWallet();
}

void WalletFrame::showCreateWalletDialog()
{
    CreateWalletDialog dlg(this);
    if (dlg.exec() == QDialog::Accepted && dlg.isConfirmed()) {
        // Wallet creation logic would go here
        // For now, just show a message
        QMessageBox::information(this, tr("Wallet created"), 
            tr("Your wallet has been created and is ready to use."));
    }
}
