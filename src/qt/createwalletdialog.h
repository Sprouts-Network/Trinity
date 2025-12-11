#ifndef CREATEWALLETDIALOG_H
#define CREATEWALLETDIALOG_H

#include <QDialog>
#include <QStringList>

namespace Ui {
class CreateWalletDialog;
}

class CreateWalletDialog : public QDialog
{
    Q_OBJECT

public:
    explicit CreateWalletDialog(QWidget *parent = nullptr);
    ~CreateWalletDialog();

    QStringList getSeedWords() const;
    bool isConfirmed() const;

private slots:
    void on_copySeedButton_clicked();
    void on_confirmButton_clicked();
    void on_seedEntry_textChanged(const QString &text);

private:
    Ui::CreateWalletDialog *ui;
    QStringList seedWords;
    bool confirmed;
    void generateSeed();
};

#endif // CREATEWALLETDIALOG_H
