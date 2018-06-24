#include "InformationReaderAndSender.h"
#include <QCoreApplication>
#include <QTimer>
#include <QByteArray>
InformationReaderAndSender::InformationReaderAndSender( QObject *parent) : QObject(parent)
{
    m_TcpSocket = new QTcpSocket(this);
    m_size=-1;
    m_countOfLoadedClusts=-1;
}

void InformationReaderAndSender::deleteLater()
{
    // qDebug() << "Delete Later Called";
    QObject::deleteLater();
    QCoreApplication::quit();
}
void InformationReaderAndSender::run(const QString & clusterName)
{
//    cv::FileStorage fsR1 ("/home/admin/.ImgSearchInfo/infoClusters.yaml",cv::FileStorage::READ);

//    std::vector < cv::String > clustNames;
//    fsR1["names"]>>m_names;
//    fsR1["pathsClust"]>>m_ClustPaths;
//    fsR1["pathsImages"]>>m_ImagePaths;
//    fsR1["clusterName"]>>clustNames;
//    fsR1.release();
//    int i = 0;
//    for(; i < m_ClustPaths.size(); ++i) {
//        if(QString(m_ClustPaths[i].c_str()).contains(clusterName)){
//            break;
//        }
//    }
//    if(!clusterName.isEmpty() && i < m_ClustPaths.size()) {
        m_code=1;
        connect(m_TcpSocket,SIGNAL(connected()),this,SLOT(sendInformation()));
        m_currentInfoToSend = QString("/home/ubuntu/trainData");

        m_TcpSocket->connectToHost(QHostAddress(QHostAddress::LocalHost).toString(), 54781);
        if(!m_TcpSocket->waitForConnected()){
            qDebug() << "Service is not active";
            QTimer::singleShot(1000, this, SLOT(deleteLater()));
            return;
        }

        //std::cout << "Connected To Server"<<std::endl;
//    } else {
//        m_code=3;
//        connect(m_TcpSocket,SIGNAL(connected()),this,SLOT(sendInformation()));
//        connect(m_TcpSocket,SIGNAL(readyRead()),   this,SLOT(onReadyReadSlot()));
//        connect(m_TcpSocket,SIGNAL(disconnected()),this,SLOT(onDisconnectedSlot()));
//        qDebug() << "There is no available cluster by the name :" << clusterName;
//        qDebug() << "\nAvailable Clusters are folows:\n";
//        m_TcpSocket->connectToHost(QHostAddress(QHostAddress::LocalHost).toString(), 54781);
//        for(int i = 0; i < m_ClustPaths.size(); ++i) {
//            std::cout << m_ClustPaths[i].c_str()<<std::endl;
//        }
//        // qDebug() << "Delete Later";
//        //QTimer::singleShot(1000, this, SLOT(deleteLater()));
//        //QCoreApplication::exit(0);
//        // qDebug() << "Exited";
//    }


}

void InformationReaderAndSender::onReadyReadSlot()
{
    qDebug()<< "Reading...";
    m_data+=m_TcpSocket->readAll();
    if(m_data.size()<=4){
        return;
    }
    if(m_size==-1){
        m_size=*(int*)m_data.left(4).data();
    }
    if(m_data.size()>=sizeof(int)+m_size){
        int countOfLoadedClusts=*(int*)m_data.mid(4,4).data();
        std::vector<QString> clustNames(countOfLoadedClusts);
        int position = 8;
        QString debug=m_data.mid(43,m_size+4).data();
        qDebug()<<debug;
        for(int i = 0 ; i <countOfLoadedClusts;++i){
            int size=*(int*)m_data.mid(position,4).data();
            qDebug()<<size;
            clustNames[i]=m_data.mid(position+4,size).data();
            position=position+size+4;
        }

        if(clustNames.size()==0){
            qDebug() << "at this moment, count of loaded clusters is 0: ";
        }
        else{
            if(clustNames.size()==1){
                qDebug() << "This Cluster has already loaded";
            }
            if(clustNames.size()>1){
                qDebug() << "This Clusters have already loaded";
            }
            for(int i = 0 ; i<clustNames.size();++i){
                qDebug()<<clustNames.at(i);
            }
        }
    }
    QTimer::singleShot(1000, this, SLOT(deleteLater()));
}
void InformationReaderAndSender::onDisconnectedSlot()
{
    std::vector<QString> loadedClusts;
    QString loadedClust;


    int position=-1;


    for ( int i = 0 ; i < m_loadedClustsPath.length();++i)
    {
        if (m_loadedClustsPath.at(i)==':'){
            loadedClust.clear();
            for ( int j = position+1 ; j<i ; ++j){
                loadedClust+=m_loadedClustsPath.at(j);
            }
            loadedClusts.push_back(loadedClust);
            position=i;
        }
    }
    if(loadedClusts.size()==0){
        qDebug() << "at this moment, count of loaded clusters is 0: ";
    }
    else{
        if(loadedClusts.size()==1){
            qDebug() << "This Cluster has already loaded";
        }
        if(loadedClusts.size()>1){
            qDebug() << "This Clusters have already loaded";
        }
        for(int i = 0 ; i<loadedClusts.size();++i){
            qDebug()<<loadedClusts.at(i);
        }
    }
    QTimer::singleShot(1000, this, SLOT(deleteLater()));

}
void InformationReaderAndSender::sendInformation()
{
   // qDebug() << "code " << m_code ;
    if(m_code==1){
        QString path=m_currentInfoToSend;
       // std::cout  <<"PATH "  <<path.toStdString();
        QByteArray data = path.toLocal8Bit();

        QByteArray operationCode((char*)&m_code, 4);

        data = operationCode + data;
        int size = data.size();
        QByteArray a((char*)&size, 4);
        data = a+data;
        QString everyThing=data.left(43).data();
//        qDebug()<< "before writting : Path With Code : "<< everyThing;
        m_TcpSocket->write(data);
        //m_TcpSocket->flush();

        if(m_TcpSocket->waitForBytesWritten()) {
            qDebug() << "Clustering Loaded";
        } else {
            qDebug() << "Unable to connect with service";
        }
        QTimer::singleShot(1000, this, SLOT(deleteLater()));
    }
    if(m_code==3){
        QString path = "getInformation";
        QByteArray data = path.toLocal8Bit();

        QByteArray operationCode((char*)&m_code, 4);

        data = operationCode + data;
        int size = data.size();
        QByteArray a((char*)&size, 4);
        data = a+data;
        m_TcpSocket->write(data);
        if(m_TcpSocket->waitForBytesWritten()) {
            qDebug() << "Information about loaded clusters";
        } else {
            qDebug() << "Unable to connect with service";
        }
    }

}
