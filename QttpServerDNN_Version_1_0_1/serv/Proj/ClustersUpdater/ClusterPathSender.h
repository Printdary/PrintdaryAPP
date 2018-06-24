#ifndef CLUSTERPATHSENDER_H
#define CLUSTERPATHSENDER_H

#include <QObject>
#include <QTcpSocket>
#include <QHostAddress>
#include <QTimer>
#include <QCoreApplication>

#include <iostream>


class ClusterPathSender : public QObject
{
    Q_OBJECT
public:
    explicit ClusterPathSender(QObject *parent = 0);
    void run(const QString & clustePath);
signals:

public slots:
    void sendInformation();
    void deleteLater();
private:
    QTcpSocket *m_TcpSocket;
    QString m_currentClusterPathToSend;
};

#endif // CLUSTERPATHSENDER_H
