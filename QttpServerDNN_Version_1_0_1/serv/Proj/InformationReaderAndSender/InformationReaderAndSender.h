#ifndef INFORMATIONREADERANDSENDER_H
#define INFORMATIONREADERANDSENDER_H

#include <QObject>
#include <QTcpSocket>
#include <QTcpServer>
#include <QNetworkInterface>
#include <string>
//#include <opencv2/imgcodecs.hpp>
//#include <opencv2/opencv.hpp>
//#include <opencv2/core/core.hpp>

class InformationReaderAndSender : public QObject
{
    Q_OBJECT
public:
    explicit InformationReaderAndSender(QObject *parent = 0);
    void run(const QString & clusterName);
signals:

public slots:
    void sendInformation();
    void onReadyReadSlot();
    void onDisconnectedSlot();
    void deleteLater();
private:
    std::vector<std::string> m_names;
    std::vector<std::string> m_ClustPaths;
    std::vector<std::string> m_ImagePaths;
    QTcpSocket *m_TcpSocket;

    QByteArray m_data;
    QString m_name;
    int m_code;
    int m_size;
    int m_countOfLoadedClusts;
    QString m_currentInfoToSend;
    QString m_loadedClustsPath;
};

#endif // INFORMATIONREADERANDSENDER_H
