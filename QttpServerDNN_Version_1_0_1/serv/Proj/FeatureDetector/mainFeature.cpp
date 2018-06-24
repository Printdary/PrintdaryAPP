#include <QCoreApplication>
#include <FeatureDetector.h>
#include <QTextStream>
#include <QDebug>
#include <QFileInfo>
#include <QDir>
#include <Controller.h>
detectorType detectorNameToEnum(const QString& name){
    if(name == "ORB"){
        return eOrbFeatureMatcher;
    } else if(name == "sift" || "SIFT" == name) {
        return eSiftFeatureMatcher;
    } else if(name == "surf" || "SURF"==name){
        return eSurfFeatureMatcher;
    }else if(name== "akaze"|| name=="AKAZE"){
        return eAkazeFeatureMatcher;
    }else {
        return eUnknownFeatureDetector;
    }
}

/// argv[1] == featureName {"ORB", "SIFT", "SURF"}
/// argv[2] == featurescount any integer number
/// argv[3] == folderPath or imagePath
///
int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
//    ParametrsForFeatureDetector params;
//    params.detectorName=eOrbFeatureMatcher;
//    params.featuresCount=400;
//    params.imagesFolder="/home/admin/bigTestData/";
//      Controller con(params,2);

    ParametrsForFeatureDetector param;

    if(argc != 5) {
        qDebug() << "Incorrect parameters list specified";
        qDebug() << "Correct Usage is :\n " << argv[0] << "[\ORB, SIFT ,SURF, AKAZE]" << " [400]" << "[image or folder path]"<<"countOfThreads";
        return -1;
    }
    param.detectorName= detectorNameToEnum(argv[1]); //eOrbFeatureMatcher;
   if(param.detectorName == eUnknownFeatureDetector) {
       qDebug() << "Unsupported Detector Type";
       return -1;
   }
   bool ok = true;
    param.featuresCount= QString(argv[2]).toInt(&ok);
    if(!ok) {
        qDebug() << "Number of features can't be threathed as integer number";
        return -1;
    }
    QString path1=argv[3];
    param.imagesFolder=argv[3];


    QFileInfo f(path1);
    if(!f.exists()) {
        QDir d(path1);
        if(!d.exists()) {
            qDebug() << "Specified image or folder path is not valid";
            return -1;
        }
    }
    int ct=QString(argv[4]).toInt(&ok);

    if(!ok) {
        qDebug() << "Number of features can't be threathed as integer number";
        return -1;
    }

    Controller con(param,ct);
    return 0;
}
