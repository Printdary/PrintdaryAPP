#include <QCoreApplication>
#include "ClusterCreateator.h"
#include <QDebug>
#include <QDir>


clusterCreatorType detectorNameToEnum(const QString& name){
    if(name == "withangles" || name== "WithAngles" || name == "WITHANGLES"){
        return eClusteringWithAngles;
    } else{
        return eUnknownClusterType;
    }
}
int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    //Clustering;;;
    if(argc != 7) {
        qDebug() << "Incorrect parameters list specified";
        qDebug() << "Correct Usage is :\n " << argv[0] << "[Cluster Type]"<<"[Extractor Name With Parametr]" << " [5-20]" << "[500-2000]"<<"ImageFolderpath"<<"clusterFolderpath";
        return -1;
    }

    ParametrsForClustering param;
    param.clusterType=detectorNameToEnum(argv[1]);

    if(param.clusterType == eUnknownClusterType){
        qDebug() << "Unsupported Cluster Type";
        return -1;
    }
    param.extractorName=argv[2];

    bool ok=true;
    param.deltaForAngle=QString(argv[3]).toInt(&ok);
    if(!ok) {
        qDebug() << "delta for angles can't be threathed as integer number";
        return -1;
    }

    param.deltaForKptsAngle=QString(argv[4]).toInt(&ok);
    if(!ok) {
        qDebug() << "delta for KptsAngles can't be threathed as integer number";
        return -1;
    }
    param.clusterFolder=argv[6];
    QString path1=argv[6];
    QDir d1(path1);
    if(!d1.exists()) {
        qDebug() << "Specified folder path is not valid";
        return -1;
    }
    param.imagesFolder=argv[5];
    path1=argv[5];
    QDir d(path1);
    if(!d.exists()) {
        qDebug() << "Specified folder path is not valid";
        return -1;
    }

    ClusterCreator clus(param);
    return 0;
}
