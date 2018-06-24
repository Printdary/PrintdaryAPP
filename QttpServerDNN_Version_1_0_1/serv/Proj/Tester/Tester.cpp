#include "Tester.h"

Tester::Tester(QString imgsDirPath,QString clustName ,QObject *parent) : QObject(parent)
  ,m_imagesDirPath(imgsDirPath)
  ,m_clustName(clustName)
{
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

void Tester::sendInformation()
{
    m_similarImgsPath = "";
    QByteArray data = m_imagesDirPath.toLocal8Bit();
    int code = 2;
    QByteArray operationCode((char*)&code, 4);

    data = operationCode + data;
    int size = data.size();
    QByteArray a((char*)&size, 4);
    data = a+data;

    QByteArray data2=m_clustName.toLocal8Bit();

    int size2=data2.size();
    QByteArray sz2((char*)&size2,4);
    data=data+sz2+data2;

    m_TcpSocket->write(data);
    if(m_TcpSocket->waitForBytesWritten()){
        qDebug()<<"Data Written:ImageSender:"<<m_imagesDirPath;
    } else {
        qDebug()<<"Data Writing failed";
    }
}
void Tester::readImagePath()
{
    qDebug()<< "Reading... ";
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

    }

}
void Tester::onDisconnectedSlot()
{
    qDebug()<<"reading";
    std::vector<QString> precents , similarImgPaths;
    QString precent , similarImgPath;
    int count =10;

    int position,position1=-1,startPos ;
    while(count){
        startPos=position1+1;
        for ( int i = position1+1 ; i < m_similarImgsPath.length();++i)
        {
            if (m_similarImgsPath.at(i)==':'){
                position =i;
                break;
            }
        }
        precent.clear();
        similarImgPath.clear();
        for ( int i = startPos ; i < position ; ++i){
            similarImgPath+=m_similarImgsPath.at(i);
        }

        similarImgPaths.push_back(similarImgPath);
        count--;
    }
    m_simillarPaths= similarImgPaths;
    couintingPrecent();


    QCoreApplication::exit(0);
}


QString Tester::nameFromPosImg(const QString &FilePath)
{
    int position, position2;
    for (size_t i = FilePath.length() - 1; i >= 0; i--) {
        if (FilePath.at(i) == '-') {
            position = i;
        }
        if (FilePath.at(i) == '\\') {
            position2 = i;
            break;
        }
    }

    QString newpath;
    for (int i = position2 + 1; i < position; ++i) {
        newpath += FilePath.at(i);
    }
    return newpath;
}

QString Tester::nameFromNormalImg(const QString &FilePath)
{
    int position, position2;
    for (size_t i = FilePath.length() - 1; i >= 0; i--) {
        if (FilePath.at(i) == '.') {
            position = i;
        }
        if (FilePath.at(i) == '\\') {
            position2 = i;
            break;
        }
    }

    QString newpath;
    for (int i = position2 + 1; i < position; ++i) {
        newpath += FilePath.at(i);
    }
    return newpath;
}

void Tester::couintingPrecent()
{
    qDebug()<< "On CouintingPrecent";
    QDir recoredDir(m_imagesDirPath);
    QStringList allFiles = recoredDir.entryList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden
                                                | QDir::AllDirs | QDir::Files, QDir::DirsFirst);

    int countOfRights=0;
    for(int i = 0 ; i < allFiles.size();++i){
        if(nameFromPosImg(m_imagesDirPath+allFiles.at(i))==nameFromNormalImg(m_similarImgsPath.at(i))){
            countOfRights++;
        }
    }
    qDebug()<< "Precent of Rights:"<<countOfRights/allFiles.size();
}

