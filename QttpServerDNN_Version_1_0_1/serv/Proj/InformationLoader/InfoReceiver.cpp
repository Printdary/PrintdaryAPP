#include "InfoReceiver.h"
//#include "ImageSender.h"
#include <QString>
InfoReceiver::InfoReceiver(QObject *parent) : QObject(parent)
{
    connectToFirstServer();
    connectToSecondServer();
    connect(m_tcpServerClust,SIGNAL(newConnection()),this,SLOT(readInformation()));
    connect(m_tcpServerImage,SIGNAL(newConnection()),this,SLOT(readImagePath()));

    m_byteArray.clear();

    m_size=-1;m_size1=-1;m_size2=-1;
}

void InfoReceiver::onReadyRead()
{

}
void InfoReceiver::readyReadImagePathChunks()
{

    qDebug()<< "reading:";
    QByteArray byteArray;
    // while(true){


    m_byteArray += m_tcpSocketClust->readAll();
    if(m_byteArray.size() <= 4){
        return;
    }
    if(m_size==-1){
        m_size=*(int*)m_byteArray.left(4).data();

    }

    //        if(m_byteArray.size() == sizeof(int)+m_size) {
    //            return;
    //        }


    if(m_byteArray.size() >= sizeof(int)+m_size) {

        m_code = *(int*)m_byteArray.mid(4,4).data();
        m_path = m_byteArray.mid(8,m_size-4);
        m_byteArray.clear();
        m_size=-1;
        qDebug() << "operation code: <"<<m_code << "> clusterPath"<< m_path;
        if(m_code == 1){
            isLoadingNow=true;
	    qDebug()<<"before Loading " ;
            m_loader.loadFile(m_path);
            qDebug()<<"Loading finished: " << m_path;
            isLoadingNow=false;
        }

        if(m_code == 2){

            qDebug() << "Path : " <<m_path;
            m_loader.updateFiles(m_path);
            qDebug()<<"Updating finished:"<< m_path;
        }

        if(m_code == 3){
            std::vector <QString> loadedClusts = m_loader.getInfo();
            QByteArray data;
            for(int i =0 ; i <loadedClusts.size();++i){
                QByteArray first=loadedClusts.at(i).toLocal8Bit();
                int sz = first.size();
                QByteArray size1((char*)&sz, 4);
                data+=size1+first;
            }
            int size=data.size();
            int count1=loadedClusts.size();
            qDebug() <<"Count Of:"<< count1;
            QByteArray count((char*)&count1,4);
            QByteArray size2((char*)&size, 4);
            data=size2+count+data;
            m_tcpSocketClust->write(data);
            if(!m_tcpSocketClust->waitForBytesWritten()) {
                qDebug() <<"Service: client socket is not available";
            } else {
                qDebug()<< "Service: Search result delivered";
            }
        }

    }
}


void InfoReceiver::onTcpClusterSocketClosed()
{

    // qDebug()<<m_tcpSocketImage->waitForConnected();
    // qDebug()<<m_path;
}
void InfoReceiver::readInformation()
{
    m_path = "";
    m_tcpSocketClust=m_tcpServerClust->nextPendingConnection();

    connect(m_tcpSocketClust, SIGNAL(readyRead()), this, SLOT(readyReadImagePathChunks()));//tcpSocketClust->waitForReadyRead();
    //connect(m_tcpSocketClust, SIGNAL(disconnected()), this, SLOT(onTcpClusterSocketClosed()));

}

QString InfoReceiver::getInfo()
{
    if(isLoadingNow==true){
        return m_path;
    }
    return "";
}

void InfoReceiver::readImagePath()
{
    if(isLoadingNow==false){
        QTcpSocket *tcpSocketImage=m_tcpServerImage->nextPendingConnection();



        qDebug()<<"size of readed files" << receivedPath.size();
        tcpSocketImage->waitForReadyRead();
        receivedPath += tcpSocketImage->readAll();
        if(receivedPath.size()<=4){
            return;
        }

        if(m_size1==-1){
            m_size1=*(int*)receivedPath.left(4).data();
        }

        if(m_size2==-1 && m_size1!=-1){
            m_size2= *(int*)receivedPath.mid(m_size1+4,4).data();
        }
        if(receivedPath.size() == sizeof(int)+m_size1+m_size2+sizeof(int)) {

            int code = *(int*)receivedPath.mid(4,4).data();
            QString name = receivedPath.mid(8,m_size1-4);
            QString clustName=receivedPath.mid(m_size1+8,m_size2-4);
            m_size1=-1;m_size2=-1;
            if(code ==1){
                qDebug() <<"Service: Received path to search " << name;
                std::vector<std::string> similarImgPath=m_loader.searchImage(name,clustName);
                qDebug()<<"paths are sending:";
                for(int i =0 ; i <similarImgPath.size();++i){
                    //            if(similarImgPath.at(i).isEmpty()) {
                    //                similarImgPath = "No Similar Image found";
                    //            }
                    //qDebug() <<"Service search finished 1" << similarImgPath;
                    qDebug()<<similarImgPath.at(i).c_str();
                    QString similarPath=QString::fromUtf8(similarImgPath.at(i).c_str());
                    tcpSocketImage->write(similarPath.toLocal8Bit());
                    if(!tcpSocketImage->waitForBytesWritten()) {
                        qDebug() <<"Service: client socket is not available";
                    } else {
                        qDebug()<< "Service: Search result delivered";
                    }
                }
                tcpSocketImage->close();
                //ImageSender(similarImgPath,0);
            receivedPath.clear();
            }else if(code==2){
                qDebug() <<" Code " << name;
                std::vector<std::string> similarImgPath=m_loader.similarImgs(name,clustName);
                qDebug()<<"paths are sending:";
                for(int i =0 ; i <similarImgPath.size();++i){
                    //            if(similarImgPath.at(i).isEmpty()) {
                    //                similarImgPath = "No Similar Image found";
                    //            }
                    //qDebug() <<"Service search finished 1" << similarImgPath;
                    qDebug()<<similarImgPath.at(i).c_str();
                    QString similarPath=QString::fromUtf8(similarImgPath.at(i).c_str());
                    tcpSocketImage->write(similarPath.toLocal8Bit());
                    if(!tcpSocketImage->waitForBytesWritten()) {
                        qDebug() <<"Service: client socket is not available";
                    } else {
                        qDebug()<< "Service: Search result delivered";
                    }
                }
//                QByteArray data;
//                for(int i =0 ; i <similarImgPath.size();++i){
//                    QByteArray first=QString::fromStdString(similarImgPath.at(i)).toLocal8Bit();
//                    int sz = first.size();
//                    QByteArray size1((char*)&sz, 4);
//                    data+=size1+first;
//                }
//                int size=data.size();
//                int count1=similarImgPath.size();
//                qDebug() <<"Count Of:"<< count1;
//                QByteArray count((char*)&count1,4);
//                QByteArray size2((char*)&size, 4);
//                data=size2+count+data;
//                tcpSocketImage->write(data);
//                if(!tcpSocketImage->waitForBytesWritten()) {
//                    qDebug() <<"Service: client socket is not available";
//                } else {
//                    qDebug()<< "Service: Search result delivered";
//                }
                 tcpSocketImage->close();

                receivedPath.clear();
            }
        }
    }
}

void InfoReceiver::connectToFirstServer()
{
    m_tcpServerClust=new QTcpServer(this);

    if(!m_tcpServerClust->listen(QHostAddress::Any,54781)){
        qDebug()<<"Server couldn't start";
    }
    else{
        qDebug()<<"Server Started ";
    }
    QString ipAddress;
    QList<QHostAddress> ipAddressesList = QNetworkInterface::allAddresses();
    for (int i = 0; i < ipAddressesList.size(); ++i) {
        if (ipAddressesList.at(i) != QHostAddress::LocalHost &&
                ipAddressesList.at(i).toIPv4Address()) {
            ipAddress = ipAddressesList.at(i).toString();
            break;
        }
    }


    if (ipAddress.isEmpty())
        ipAddress = QHostAddress(QHostAddress::LocalHost).toString();

}
void InfoReceiver::connectToSecondServer()
{
    m_tcpServerImage=new QTcpServer(this);

    if(!m_tcpServerImage->listen(QHostAddress::Any,54782)){
        qDebug()<<"Server couldn't start";
    }
    else{
        qDebug()<<"Server Started ";
    }
    QString ipAddress;
    QList<QHostAddress> ipAddressesList = QNetworkInterface::allAddresses();
    for (int i = 0; i < ipAddressesList.size(); ++i) {
        if (ipAddressesList.at(i) != QHostAddress::LocalHost &&
                ipAddressesList.at(i).toIPv4Address()) {
            ipAddress = ipAddressesList.at(i).toString();
            break;
        }
    }


    if (ipAddress.isEmpty())
        ipAddress = QHostAddress(QHostAddress::LocalHost).toString();

}
void InfoReceiver::sendImagePath( QString path)
{
    QTcpSocket *tcpSocketImage=m_tcpServerImage->nextPendingConnection();
    QByteArray data = path.toLocal8Bit();
    tcpSocketImage->write(data);
    tcpSocketImage->flush();

}
