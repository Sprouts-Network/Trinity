#include "createwalletdialog.h"
#include "ui_createwalletdialog.h"

#include <QClipboard>
#include <QMessageBox>
#include <random>

// Dummy simple BIP39 generator (replace with full if desired)
static QStringList generateRandomSeedWords()
{
    static const QStringList wordlist = {
        "abandon", "ability", "able", "about", "above", "absent",
        // ... (rest of 2048 English BIP39 words in full implementation)
        "zone", "zoo"
    };
    std::random_device rd;
    std::mt19937 rng(rd());
    QStringList out;
    for (int i=0; i<12; ++i)
        out << wordlist[rng() % wordlist.size()];
    return out;
}

CreateWalletDialog::CreateWalletDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::CreateWalletDialog),
    confirmed(false)
{
    ui->setupUi(this);
    generateSeed();
    ui->confirmButton->setEnabled(false);
    connect(ui->seedEntry, &QLineEdit::textChanged, this, &CreateWalletDialog::on_seedEntry_textChanged);
}

CreateWalletDialog::~CreateWalletDialog()
{
    delete ui;
}

void CreateWalletDialog::generateSeed()
{
    seedWords = generateRandomSeedWords();
    ui->seedDisplay->setText(seedWords.join(" "));
}

void CreateWalletDialog::on_copySeedButton_clicked()
{
    QClipboard *clipboard = QApplication::clipboard();
    clipboard->setText(ui->seedDisplay->text());
    QMessageBox::information(this, tr("Copied!"), tr("Seed phrase copied to clipboard."));
}

void CreateWalletDialog::on_confirmButton_clicked()
{
    if (ui->seedEntry->text().trimmed().split(" ") == seedWords) {
        confirmed = true;
        accept();
    } else {
        QMessageBox::warning(this, tr("Incorrect"), tr("The seed phrase entered does not match. Please try again."));
    }
}

void CreateWalletDialog::on_seedEntry_textChanged(const QString &text)
{
    ui->confirmButton->setEnabled(text.trimmed().split(" ").length() == 12);
}

QStringList CreateWalletDialog::getSeedWords() const
{
    return seedWords;
}

bool CreateWalletDialog::isConfirmed() const
{
    return confirmed;
}
