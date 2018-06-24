#include <QCoreApplication>
#include <InfoReceiver.h>
//#include <ImageSender.h>
#include <QProcess>
#include <QString>
int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
/*    std::string a1=argv[1] , b = argv[2];
    std::vector <float> av =InfoProvider::readFeatureFromFile(a1) , bv= InfoProvider::readFeatureFromFile(b);
float t=0;    
for(int i = 0 ; i < 128;++i){
        qDebug()<<t;
	t+=std::abs(av[i]-bv[i]);
} */   
  
//    qDebug() << " NUM " <<std::sqrt(t);
    InfoReceiver obj;
    QProcess *Config=new QProcess();
    QString file1="/home/ubuntu/bin/config";
    QStringList params;
    Config->start(file1,params);

    return a.exec();
}
