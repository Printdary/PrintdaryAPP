#ifndef INFORECEIVER_H
#define INFORECEIVER_H

#include <QObject>
#include <QTcpSocket>
#include <QTcpServer>
#include <QHostAddress>
#include <QNetworkInterface> 
#include "Loader.h"

class InfoReceiver : public QObject
{
    Q_OBJECT
public:
    explicit InfoReceiver(QObject *parent = 0);
    QString getInfo();
private:
    void connectToFirstServer();
    void connectToSecondServer();
signals:

public slots:
    void onReadyRead();
    void readInformation();
    void readImagePath();
    void sendImagePath( QString path);
    void readyReadImagePathChunks();
    void onTcpClusterSocketClosed();

private:
    QTcpServer *m_tcpServerClust;
    QTcpServer *m_tcpServerImage;
    QString m_path;

    Loader m_loader;

    bool isLoadingNow;
    QTcpSocket *m_tcpSocketClust;
    QTcpSocket *m_tcpSocketImage;

    QByteArray m_byteArray;
    QByteArray receivedPath ;
    int m_size1;
    int m_size2;
    int m_size;
    int m_code;
};

#endif // INFORECEIVER_H
