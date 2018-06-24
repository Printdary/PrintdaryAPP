#include <QCoreApplication>
#include "ImageSender.h"
//#include "ImageReceiver.h"
#include <QString>

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    if(argc != 3) {
        qDebug() << "Incorrect parameters list specified";
        qDebug() << "Correct Usage is :\n " << argv[0] << "imagepath "<<"clusterName" ;
        return -1;
    }

    QString imgPath=argv[1];
    //cv::Mat img = cv::imread(argv[1]);
    //if(img.empty()){
    //    qDebug()<<"Specified image path is not valid";
    //}

    QString clustName=argv[2];

    ImageSender obj(imgPath,clustName,0);
    return a.exec();
}
