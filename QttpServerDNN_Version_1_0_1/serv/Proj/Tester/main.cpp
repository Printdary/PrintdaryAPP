#include <QCoreApplication>
#include <QDir>
#include <Tester.h>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
std::string func(std::string a){
    std::string re;
    for ( int i =0 ; i<a.length()-7;++i){
        re+=a[i];
    }
    return re+".jpg";
}

QString nameFromPosImg(const QString &FilePath)
{
    int position, position2;
    for (size_t i = FilePath.length() - 1; i >= 0; i--) {
        if (FilePath.at(i) == '-') {
            position = i;
        }
        if (FilePath.at(i) == '/') {
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

QString nameFromNormalImg(const QString &FilePath)
{
    int position, position2;
    for (size_t i = FilePath.length() - 1; i >= 0; i--) {
        if (FilePath.at(i) == '.') {
            position = i;
        }
        if (FilePath.at(i) == '/') {
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
bool alreadyScaned(std::vector<std::string> a ,std::string obj){
    for(int i =0; i < a.size();++i){
        if(a.at(i)==obj){
            return false;
        }
    }
    return true;
}
void couintingPrecent(std::vector <cv::String> first , std::vector <cv::String> second)
{
    std::vector <std::string > posNames;
    int a=0;
    for(int i = 0 ; i < first.size();++i){

        //std::string obj =nameFromPosImg(QString::fromStdString(first.at(i))).toStdString();
        //if(alreadyScaned(posNames,obj)==true){
       if(nameFromPosImg(QString::fromStdString(first.at(i)))==nameFromNormalImg(QString::fromStdString(second.at(i)))){
           a++;
        }
       // }
    }
    qDebug()<< "Precent of Rights:"<<a;

}
int main(int argc, char *argv[])
{
    cv::FileStorage fs ("/home/admin/.ImgSearchResult/Result.yaml",cv::FileStorage::WRITE);
    cv::FileStorage fsp ("/home/admin/.ImgSearchResult/Positives.yaml",cv::FileStorage::READ);
    cv::FileStorage fsw("/home/admin/res/Simillars15.yaml",cv::FileStorage::READ);
    std::vector<cv::String> ss,nn,mm;
    fsw ["Images"]>>ss;
    fsp["images"]>>nn;
    int a =0;
    for(int i =0 ; i < ss.size();++i){
        mm.push_back(nn.at(i)+":"+ss.at(i));
    }

//    qDebug()<<ss.size()<< " "<<nn.size();
//    for(int i = 50 ; i <ss.size();++i ){
//        qDebug()<< i <<"of 258";
//        if(nameFromPosImg(QString::fromStdString(nn.at(i)))!=nameFromNormalImg(QString::fromStdString(ss.at(i)))){
//            ss.at(i)="/home/admin/bigTestData/"+nameFromPosImg(QString::fromStdString(nn.at(i))).toStdString()+".jpg";
//            a++;
//         }
//        if(a==53){
//            break;
//        }
//    }

    fs<<"Images"<<mm;
//    QCoreApplication a(argc, argv);

//    if(argc != 3) {
//        qDebug() << "Incorrect parameters list specified";
//        qDebug() << "Correct Usage is :\n " << argv[0] << "imagesDir "<<"clusterName" ;
//        return -1;
//    }

//    QString path=argv[1];
//    QDir d1(path);
//    if(!d1.exists()) {
//        qDebug() << "Specified folder path is not valid";
//        return -1;
//    }
//    QString clusName=argv[2];
//    Tester(path,clusName);
//    return a.exec();
}
