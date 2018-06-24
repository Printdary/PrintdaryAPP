#include "ImageSender.h"
#include <QCoreApplication>

ImageSender::ImageSender(QString imagePath,QString clusterName,QObject *parent) : QObject(parent)
{
    if(sendImage(imagePath)==true){
        m_clusterName=clusterName;
        m_TcpSocket = new QTcpSocket();

        connect(m_TcpSocket,SIGNAL(connected()),this,SLOT(sendInformation()));
        connect(m_TcpSocket,SIGNAL(readyRead()),this,SLOT(readImagePath()));
        connect(m_TcpSocket,SIGNAL(disconnected()),this,SLOT(onDisconnectedSlot()));
        m_TcpSocket->connectToHost(QHostAddress(QHostAddress::LocalHost).toString(), 54782);
        if(!m_TcpSocket->waitForConnected()){
            qDebug() << "Unable to connect with Service:ImageSender";
        } else {
            qDebug() << "Connected with Service:ImageSender";
        }

    }

}

void ImageSender::sendInformation()
{
    m_similarImgPath = "";
    QByteArray data = m_imagePath.toLocal8Bit();
    int code = 1;
    QByteArray operationCode((char*)&code, 4);

    data = operationCode + data;
    int size = data.size();
    QByteArray sz((char*)&size, 4);
    data = sz+data;

    QByteArray data2=m_clusterName.toLocal8Bit();

    int size2=data2.size();
    QByteArray sz2((char*)&size2,4);
    data=data+sz2+data2;

//    QString forDebug=QString::fromAscii(data.data());
//    qDebug()<< "our data:"<<forDebug;
    qDebug()<<"sizeOf(writenFiles)="<<m_TcpSocket->write(data);
    if(m_TcpSocket->waitForBytesWritten()){
        qDebug()<<"Data Written:ImageSender:"<<m_imagePath.size();
    } else {
        qDebug()<<"Data Writing failed";
    }

}
bool ImageSender::sendImage(QString imagePath)
{
    std::string path=imagePath.toUtf8().constData();
    

  //  if(path.substr(path.length()-3,3)!="png"){
  //      return false;
  //  }
    m_imagePath=imagePath;
    return true;

}

void ImageSender::readImagePath()
{

    QByteArray data=m_TcpSocket->readAll();
    // qDebug() << "ImageSender: data chunk" << data;
    m_similarImgPath += QString::fromLocal8Bit(data.data());
    //qDebug()<<"Similar img path :"<<m_similarImgPath;
}
void ImageSender::onDisconnectedSlot()
{
    std::vector<QString> precents , similarImgPaths;
    QString precent , similarImgPath;
    int count =10;

    int position,position1=-1,startPos ;
    while(count){
        startPos=position1+1;
        for ( int i = position1+1 ; i < m_similarImgPath.length();++i)
        {
            if (m_similarImgPath.at(i)==':'){
                position =i;
                break;
            }
        }
        for ( int i = position+1 ; i < m_similarImgPath.length();++i)
        {
            if (m_similarImgPath.at(i)==':'){
                position1 =i;
                break;
            }
        }
        precent.clear();
        similarImgPath.clear();
        for ( int i = startPos ; i < position ; ++i){
            precent+=m_similarImgPath.at(i);
        }
        for (int i =position+1 ; i < position1;++i){
            similarImgPath+=m_similarImgPath.at(i);
        }
        precents.push_back(precent);
        similarImgPaths.push_back(similarImgPath);
        count--;
    }
    std::vector < float> precentf;
    for(int i = 0 ; i < precents.size();++i){
        precentf.push_back(precents.at(i).toFloat()*100);

    }
    for(int i = 0 ; i < precentf.size();++i){
        for ( int j = i ; j<precentf.size();++j ){
            if(precentf.at(i)<precentf.at(j)){
                std::swap(precentf.at(i),precentf.at(j));
                std::swap(similarImgPaths.at(i),similarImgPaths.at(j));
            }
        }
    }
    for ( int i = 0 ; i < precents.size();++i){
        qDebug() << "Precent Of Similarity:" << precentf.at(i) << "%";
        qDebug() << "Similar Image Path:" << similarImgPaths.at(i);
    }


    QCoreApplication::exit(0);
}
