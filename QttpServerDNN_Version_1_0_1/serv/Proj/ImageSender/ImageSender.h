#ifndef IMAGESENDER_H
#define IMAGESENDER_H

#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>
#include <QNetworkInterface>

//#include <opencv2/imgcodecs.hpp>
//#include <opencv2/opencv.hpp>
//#include <opencv2/core/core.hpp>

class ImageSender : public QObject
{
    Q_OBJECT
public:
    explicit ImageSender(QString imgPath,QString clusterName,QObject *parent = 0);
    bool sendImage(QString imagePath);
signals:

public slots:
    void sendInformation();
    void readImagePath();
    void onDisconnectedSlot();
private:
    QTcpSocket *m_TcpSocket;

    QString m_clusterName;
    QString m_similarImgPath;
    QString m_imagePath;
};

#endif // IMAGESENDER_H
