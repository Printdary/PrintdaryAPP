#include "FeatureDetector.h"
#include <QDir>
#include <QDebug>
#include <QThread>
FeatureDetector::FeatureDetector()
{

}

void FeatureDetector::run(const ParametrsForFeatureDetector &Params, const std::vector<cv::String> &vec)
{
    qDebug () << QThread::currentThreadId();
    qDebug()<<s++;
    m_detector=detectFeatureMatcherType(Params.detectorName);
    if(createFeatures(Params,vec)==false){
        std :: cout << "Feature Detection Failed !!!";
    }
    //infoAboutThis(Params);
}
FeatureMatcher * FeatureDetector::detectFeatureMatcherType(const detectorType &type)
{
    FeatureMatcher *detector;
    switch (type) {
    case eAkazeFeatureMatcher:
        detector= new AkazeFeatureMatcher();
        m_detectorName="Akaze";
        break;
    case eOrbFeatureMatcher:
        detector= new ORBFeatureMatcher();
        m_detectorName="Orb";
        break;
    case eSurfFeatureMatcher:
        detector= new SurfFeatureMatcher();
        m_detectorName="Surf";
        break;
    case eSiftFeatureMatcher:
        detector= new SiftFeatureMatcher();
        m_detectorName="Sift";
        break;
    }
    return detector;
}
bool FeatureDetector:: createFeatures(const ParametrsForFeatureDetector &Params,const std::vector<cv::String> & vec)
{

    std::vector <cv::String> imageNames;
    //cv::glob(Params.imagesFolder,imageNames,true);
    imageNames=vec;
    std::stringstream ss1;
    ss1 << Params.featuresCount;
    std::string str1 = ss1.str();
    qDebug() << vec.size();

    for(size_t i =0 ; i < imageNames.size();++i){
        if(isFormatYaml(imageNames.at(i))==false){
            cv::Mat img =cv::imread(imageNames.at(i));

            std::string pathYaml=Params.imagesFolder+imageName(imageNames.at(i))+m_detectorName+str1+".yaml";
            std::cout<<Params.featuresCount<<std::endl;
            std::cout << '\r';
            std::cout << "Progress : " << (100 *( i + 1))/(imageNames.size()) <<"%"<<std::flush;


            m_detector->featuresInYaml(img,Params.featuresCount,pathYaml);
        }
    }
    std::cout << std::endl;


    return true;


}

void FeatureDetector::infoAboutThis(ParametrsForFeatureDetector Params)
{
    cv::FileStorage fsR ("/home/admin/.ImgSearchInfo/infoFeatures.yaml",cv::FileStorage::READ);


    std::stringstream ss;
    ss << Params.featuresCount;
    std::string str = ss.str();
    switch (Params.detectorName) {
    case eAkazeFeatureMatcher:

        m_detectorName="Akaze";
        break;
    case eOrbFeatureMatcher:

        m_detectorName="Orb";
        break;
    case eSurfFeatureMatcher:

        m_detectorName="Surf";
        break;
    case eSiftFeatureMatcher:

        m_detectorName="Sift";
        break;
    }

    std :: string name =m_detectorName+str;
    std::vector <cv::String> detectorname;
    std::vector <cv::String> names;
    std::vector <cv::String> paths;

    fsR["detectorname"]>>detectorname;
    fsR["names"]>>names;
    fsR["paths"]>>paths;

    names.push_back(name);
    paths.push_back(Params.imagesFolder);
    detectorname.push_back(m_detectorName);

    cv::FileStorage fs ("/home/admin/.ImgSearchInfo/infoFeatures.yaml",cv::FileStorage::WRITE);
    fs<<"detectorname"<<detectorname;
    fs << "names" <<names;
    fs << "paths" <<paths;

}

std::string FeatureDetector::imageName(std::string Path)
{
    int position1, position2;
    for ( int i = Path.length()-1;i>=0;--i){
        if(Path.at(i)=='.'){
            position2=i;
            break;
        }
    }
    for ( int i = Path.length()-1;i>=0;--i){
        if(Path.at(i)=='/'){
            position1=i;
            break;
        }
    }
    std::string names;
    for(int i = position1+1;i<position2;++i){
        names+=Path.at(i);
    }
    return names;
}

bool FeatureDetector::isFormatYaml(std::string path)
{
    int position;
    for (int i =path.length()-1;i>=0;--i){
        if(path.at(i)=='.'){
            position=i;
            break;
        }
    }
    std::string format;
    for (int i =position+1;i<path.size();++i){
        format+=path.at(i);
    }
    if(format=="yaml"){
        return true;
    }
    return false;
}

