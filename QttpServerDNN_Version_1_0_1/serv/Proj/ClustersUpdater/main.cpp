#include <QCoreApplication>
#include <ClusterUpdater.h>
#include <QDebug>
#include <QDir>

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    if(argc !=2){
        qDebug() << "Incorrect parameters list specified";
        qDebug() << "Correct Usage is :\n " << argv[0] << "ImagePaths";
        return -1;
    }
    ClusterUpdater obj;
    std::string imagePath=argv[1];
    QString path1=argv[1];
    QDir d1(path1);

    //std::string  clusterPath=argv[2];
    //path1=argv[2];
    //QDir d(path1);
    //if(!d.exists()) {
    //    qDebug() << "Specified folder path is not valid";
    //    return -1;
    //}

    obj.run(imagePath);
    return 0;
}
