#ifndef TESTER_H
#define TESTER_H

#include <QDir>
#include <QObject>
#include <QTcpSocket>
#include <QHostAddress>
#include <QCoreApplication>

class Tester : public QObject
{
    Q_OBJECT
public:
    explicit Tester(QString imgsDirPath, QString clustName, QObject *parent = 0);

signals:
private:
    void couintingPrecent();
    QString nameFromPosImg(const QString &FilePath);
    QString nameFromNormalImg(const QString &FilePath);
public slots:
    void sendInformation();
    void readImagePath();
    void onDisconnectedSlot();
private:
    QTcpSocket *m_TcpSocket;

    QString m_similarImgsPath;
    QString m_imagesDirPath;
    QString m_clustName;

    QByteArray m_data;
    int m_size;
    std::vector<QString> m_simillarPaths;
};

#endif // TESTER_H
