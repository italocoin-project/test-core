// Copyright (c) 2014-2018, The Italocoin Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QStandardPaths>
#include <QIcon>
#include <QDebug>
#include <QObject>
#include <QDesktopWidget>
#include <QScreen>
#include "clipboardAdapter.h"
#include "filter.h"
#include "oscursor.h"
#include "oshelper.h"
#include "WalletManager.h"
#include "Wallet.h"
#include "QRCodeImageProvider.h"
#include "PendingTransaction.h"
#include "UnsignedTransaction.h"
#include "TranslationManager.h"
#include "TransactionInfo.h"
#include "TransactionHistory.h"
#include "model/TransactionHistoryModel.h"
#include "model/TransactionHistorySortFilterModel.h"
#include "AddressBook.h"
#include "model/AddressBookModel.h"
#include "Subaddress.h"
#include "model/SubaddressModel.h"
#include "wallet/api/wallet2_api.h"
#include "MainApp.h"

// IOS exclusions
#ifndef Q_OS_IOS
#include "daemon/DaemonManager.h"
#endif

#ifdef WITH_SCANNER
#include "QrCodeScanner.h"
#endif

bool isIOS = false;
bool isAndroid = false;
bool isWindows = false;
bool isDesktop = false;

void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    // Send all message types to logger
    Italocoin::Wallet::debug("qml", msg.toStdString());
}

int main(int argc, char *argv[])
{
    // platform dependant settings
#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    bool isDesktop = true;
#elif defined(Q_OS_ANDROID)
    bool isAndroid = true;
#elif defined(Q_OS_IOS)
    bool isIOS = true;
#endif
#ifdef Q_OS_WIN
    bool isWindows = true;
#endif

    // disable "QApplication: invalid style override passed" warning
    if (isDesktop) putenv((char*)"QT_STYLE_OVERRIDE=fusion");
#ifdef Q_OS_LINUX
    // force platform xcb
    if (isDesktop) putenv((char*)"QT_QPA_PLATFORM=xcb");
#endif

//    // Enable high DPI scaling on windows & linux
//#if !defined(Q_OS_ANDROID) && QT_VERSION >= 0x050600
//    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
//    qDebug() << "High DPI auto scaling - enabled";
//#endif

    MainApp app(argc, argv);

    app.setApplicationName("italocoin-gui");
    app.setOrganizationDomain("getitalocoin.org");
    app.setOrganizationName("italocoin-project");

#if defined(Q_OS_LINUX)
    if (isDesktop) app.setWindowIcon(QIcon(":/images/appicon.ico"));
#endif

    filter *eventFilter = new filter;
    app.installEventFilter(eventFilter);

    QCommandLineParser parser;
    parser.addHelpOption();
    parser.process(app);

    Italocoin::Utils::onStartup();

    // Log settings
    Italocoin::Wallet::init(argv[0], "italocoin-wallet-gui");
//    qInstallMessageHandler(messageHandler);

    qDebug() << "app startd";

    // screen settings
    // Mobile is designed on 128dpi
    qreal ref_dpi = 128;
    QRect geo = QApplication::desktop()->availableGeometry();
    QRect rect = QGuiApplication::primaryScreen()->geometry();
    qreal dpi = QGuiApplication::primaryScreen()->logicalDotsPerInch();
    qreal physicalDpi = QGuiApplication::primaryScreen()->physicalDotsPerInch();
    qreal calculated_ratio = physicalDpi/ref_dpi;

    qWarning().nospace() << "Qt:" << QT_VERSION_STR << " | screen: " << rect.width()
                         << "x" << rect.height() << " - dpi: " << dpi << " - ratio:"
                         << calculated_ratio;


    // registering types for QML
    qmlRegisterType<clipboardAdapter>("italocoinComponents.Clipboard", 1, 0, "Clipboard");

    qmlRegisterUncreatableType<Wallet>("italocoinComponents.Wallet", 1, 0, "Wallet", "Wallet can't be instantiated directly");


    qmlRegisterUncreatableType<PendingTransaction>("italocoinComponents.PendingTransaction", 1, 0, "PendingTransaction",
                                                   "PendingTransaction can't be instantiated directly");

    qmlRegisterUncreatableType<UnsignedTransaction>("italocoinComponents.UnsignedTransaction", 1, 0, "UnsignedTransaction",
                                                   "UnsignedTransaction can't be instantiated directly");

    qmlRegisterUncreatableType<WalletManager>("italocoinComponents.WalletManager", 1, 0, "WalletManager",
                                                   "WalletManager can't be instantiated directly");

    qmlRegisterUncreatableType<TranslationManager>("italocoinComponents.TranslationManager", 1, 0, "TranslationManager",
                                                   "TranslationManager can't be instantiated directly");



    qmlRegisterUncreatableType<TransactionHistoryModel>("italocoinComponents.TransactionHistoryModel", 1, 0, "TransactionHistoryModel",
                                                        "TransactionHistoryModel can't be instantiated directly");

    qmlRegisterUncreatableType<TransactionHistorySortFilterModel>("italocoinComponents.TransactionHistorySortFilterModel", 1, 0, "TransactionHistorySortFilterModel",
                                                        "TransactionHistorySortFilterModel can't be instantiated directly");

    qmlRegisterUncreatableType<TransactionHistory>("italocoinComponents.TransactionHistory", 1, 0, "TransactionHistory",
                                                        "TransactionHistory can't be instantiated directly");

    qmlRegisterUncreatableType<TransactionInfo>("italocoinComponents.TransactionInfo", 1, 0, "TransactionInfo",
                                                        "TransactionHistory can't be instantiated directly");
#ifndef Q_OS_IOS
    qmlRegisterUncreatableType<DaemonManager>("italocoinComponents.DaemonManager", 1, 0, "DaemonManager",
                                                   "DaemonManager can't be instantiated directly");
#endif
    qmlRegisterUncreatableType<AddressBookModel>("italocoinComponents.AddressBookModel", 1, 0, "AddressBookModel",
                                                        "AddressBookModel can't be instantiated directly");

    qmlRegisterUncreatableType<AddressBook>("italocoinComponents.AddressBook", 1, 0, "AddressBook",
                                                        "AddressBook can't be instantiated directly");

    qmlRegisterUncreatableType<SubaddressModel>("italocoinComponents.SubaddressModel", 1, 0, "SubaddressModel",
                                                        "SubaddressModel can't be instantiated directly");

    qmlRegisterUncreatableType<Subaddress>("italocoinComponents.Subaddress", 1, 0, "Subaddress",
                                                        "Subaddress can't be instantiated directly");

    qRegisterMetaType<PendingTransaction::Priority>();
    qRegisterMetaType<TransactionInfo::Direction>();
    qRegisterMetaType<TransactionHistoryModel::TransactionInfoRole>();

    qRegisterMetaType<NetworkType::Type>();
    qmlRegisterType<NetworkType>("italocoinComponents.NetworkType", 1, 0, "NetworkType");

#ifdef WITH_SCANNER
    qmlRegisterType<QrCodeScanner>("italocoinComponents.QRCodeScanner", 1, 0, "QRCodeScanner");
#endif

    QQmlApplicationEngine engine;

    OSCursor cursor;
    engine.rootContext()->setContextProperty("globalCursor", &cursor);
    OSHelper osHelper;
    engine.rootContext()->setContextProperty("oshelper", &osHelper);

    engine.rootContext()->setContextProperty("walletManager", WalletManager::instance());

    engine.rootContext()->setContextProperty("translationManager", TranslationManager::instance());

    engine.addImageProvider(QLatin1String("qrcode"), new QRCodeImageProvider());

    engine.rootContext()->setContextProperty("mainApp", &app);

    engine.rootContext()->setContextProperty("qtRuntimeVersion", qVersion());

// Exclude daemon manager from IOS
#ifndef Q_OS_IOS
    const QStringList arguments = QCoreApplication::arguments();
    DaemonManager * daemonManager = DaemonManager::instance(&arguments);
    engine.rootContext()->setContextProperty("daemonManager", daemonManager);
#endif

//  export to QML italocoin accounts root directory
//  wizard is talking about where
//  to save the wallet file (.keys, .bin), they have to be user-accessible for
//  backups - I reckon we save that in My Documents\Italocoin Accounts\ on
//  Windows, ~/Italocoin Accounts/ on nix / osx
#if defined(Q_OS_WIN) || defined(Q_OS_IOS)
    QStringList italocoinAccountsRootDir = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation);
#else
    QStringList italocoinAccountsRootDir = QStandardPaths::standardLocations(QStandardPaths::HomeLocation);
#endif

    engine.rootContext()->setContextProperty("isWindows", isWindows);
    engine.rootContext()->setContextProperty("isIOS", isIOS);
    engine.rootContext()->setContextProperty("isAndroid", isAndroid);

    engine.rootContext()->setContextProperty("screenWidth", geo.width());
    engine.rootContext()->setContextProperty("screenHeight", geo.height());
#ifdef Q_OS_ANDROID
    engine.rootContext()->setContextProperty("scaleRatio", calculated_ratio);
#else
    engine.rootContext()->setContextProperty("scaleRatio", 1);
#endif


    if (!italocoinAccountsRootDir.empty())
    {
        QString italocoinAccountsDir = italocoinAccountsRootDir.at(0) + "/Italocoin/wallets";
        engine.rootContext()->setContextProperty("italocoinAccountsDir", italocoinAccountsDir);
    }


    // Get default account name
    QString accountName = qgetenv("USER"); // mac/linux
    if (accountName.isEmpty())
        accountName = qgetenv("USERNAME"); // Windows
    if (accountName.isEmpty())
        accountName = "My italocoin Account";

    engine.rootContext()->setContextProperty("defaultAccountName", accountName);
    engine.rootContext()->setContextProperty("applicationDirectory", QApplication::applicationDirPath());

    bool builtWithScanner = false;
#ifdef WITH_SCANNER
    builtWithScanner = true;
#endif
    engine.rootContext()->setContextProperty("builtWithScanner", builtWithScanner);

    // Load main window (context properties needs to be defined obove this line)
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));
    if (engine.rootObjects().isEmpty())
    {
        qCritical() << "Error: no root objects";
        return 1;
    }
    QObject *rootObject = engine.rootObjects().first();
    if (!rootObject)
    {
        qCritical() << "Error: no root objects";
        return 1;
    }

#ifdef WITH_SCANNER
    QObject *qmlCamera = rootObject->findChild<QObject*>("qrCameraQML");
    if (qmlCamera)
    {
        qDebug() << "QrCodeScanner : object found";
        QCamera *camera_ = qvariant_cast<QCamera*>(qmlCamera->property("mediaObject"));
        QObject *qmlFinder = rootObject->findChild<QObject*>("QrFinder");
        qobject_cast<QrCodeScanner*>(qmlFinder)->setSource(camera_);
    }
    else
        qDebug() << "QrCodeScanner : something went wrong !";
#endif

    QObject::connect(eventFilter, SIGNAL(sequencePressed(QVariant,QVariant)), rootObject, SLOT(sequencePressed(QVariant,QVariant)));
    QObject::connect(eventFilter, SIGNAL(sequenceReleased(QVariant,QVariant)), rootObject, SLOT(sequenceReleased(QVariant,QVariant)));
    QObject::connect(eventFilter, SIGNAL(mousePressed(QVariant,QVariant,QVariant)), rootObject, SLOT(mousePressed(QVariant,QVariant,QVariant)));
    QObject::connect(eventFilter, SIGNAL(mouseReleased(QVariant,QVariant,QVariant)), rootObject, SLOT(mouseReleased(QVariant,QVariant,QVariant)));

    return app.exec();
}
