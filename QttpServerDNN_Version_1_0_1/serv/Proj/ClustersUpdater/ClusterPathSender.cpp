#include "ClusterPathSender.h"

ClusterPathSender::ClusterPathSender(QObject *parent) : QObject(parent)
{
    m_TcpSocket = new QTcpSocket(this);
}

 void ClusterPathSender::run(const QString & clusterPath)
 {
     connect(m_TcpSocket,SIGNAL(connected()),this,SLOT(sendInformation()));

     m_currentClusterPathToSend = QString(clusterPath);

     m_TcpSocket->connectToHost(QHostAddress(QHostAddress::LocalHost).toString(), 54781);
     if(!m_TcpSocket->waitForConnected()){
         qDebug() << "Service is not active";
         return;
     }

     std::cout << "Connected To Server"<<std::endl;
 }

 void ClusterPathSender::sendInformation()
 {
     QString path=m_currentClusterPathToSend;
     std::cout  <<"PATH "  <<path.toStdString();
     QByteArray data = path.toLocal8Bit();
     int code = 2;
     QByteArray operationCode((char*)&code, 4);

     data = operationCode + data;
     int size = data.size();
     QByteArray a((char*)&size, 4);
     data = a+data;
     m_TcpSocket->write(data);
     //m_TcpSocket->flush();

     if(m_TcpSocket->waitForBytesWritten()) {
         qDebug() << "Clustering Loaded";
     } else {
         qDebug() << "Unable to connect with service";
     }
     QTimer::singleShot(1000, this, SLOT(deleteLater()));
 }
 void ClusterPathSender::deleteLater()
 {
     QObject::deleteLater();
     QCoreApplication::quit();
 }
