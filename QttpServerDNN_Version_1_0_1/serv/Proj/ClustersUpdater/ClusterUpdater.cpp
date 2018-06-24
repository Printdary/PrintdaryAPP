#include "ClusterUpdater.h"
#include <sstream>
#include <fstream>
ClusterUpdater::ClusterUpdater()
{

}
void ClusterUpdater::run(const std::string &imagePath)
{
    //detectParameters(imagePath,clusterPath);
    //qDebug()<< "after Detecting Params " ;
    //runFeatureDetector(countOfThreads);
    //qDebug()<< " after Detection";
    //runClustering();
    //qDebug() << "after Clusterin";
    std::cout << " before Reaading" << std::endl;
    std::vector<std::string> names=readFeatureFromFile("/home/ubuntu/trainData/mapping.map");
    std::cout << "after Reading" << names.at(names.size()-1)<<std::endl;
    int pos=-1;
    for( int i = names.size()-1; i>=0;i--){
	if(names.at(i).length()!=0){
		pos =i ;
		break;
	}
    }
    int posit = names.at(pos).find_first_of(':');
    std::cout << " last position " <<posit ;
    std::cout << "after Reading" << names.at(pos)<<std::endl;
    std::string number = names.at(pos).substr(0, posit);
    std::stringstream convert, convert1;
    convert << number;
    int num;
    convert>>num;
    std::cout << "Num : " << num << std::endl;
    num++;
    std::cout << "Num : " << num << std::endl;

    convert1  <<num;
    number.clear();
    convert1 >>number;
    std::string n=number+":"+imagePath;
    std::cout << n <<std::endl;
    std::vector < std::string > ::iterator it ;
    it = names.begin()+pos+1;
    names.insert(it,number+":"+imagePath);
    std::string _path="/home/ubuntu/trainData/mapping.map";
    std::ofstream outMapping(_path.c_str());
    for(int i = 0; i < names.size(); ++i) {
        outMapping << names.at(i)+"\n";
    }
    sendPath(n);
    qDebug()<< " Updateing finished";
}

std::vector<std::string> ClusterUpdater::readFeatureFromFile(const std::string & path) {
	std::vector< std::string > reVal;
	std::ifstream reader;
	reader.open(path.c_str());

	while (!reader.eof()) {
		std::string ValStr;
		reader >> ValStr;
		std::stringstream convert;

		reVal.push_back(ValStr);
	}

	return reVal;

}

/*void ClusterUpdater::detectParameters(const std::string & imagePath, const std::string & clusterPath)
{

    cv::FileStorage fs("/root/.info/parameters.yaml",cv::FileStorage::READ);
    fs["fdImagesPath"]>>m_paramsForFeatureDetector.imagesFolder;
    fs["fdFeatureCount"]>>m_paramsForFeatureDetector.featuresCount;
    //fs["ccType"]>>0;
    fs["ccImagesPath"]>>m_paramsForClustering.imagesFolder;
    fs["ccDeltaForAngle"]>> m_paramsForClustering.deltaForAngle;
    fs["ccDeltaForKptsAngle"]>>m_paramsForClustering.deltaForKptsAngle;
    fs["ccClusterPath"]>>m_paramsForClustering.clusterFolder;
    std::cout << m_paramsForFeatureDetector.imagesFolder <<m_paramsForFeatureDetector.featuresCount<<m_paramsForClustering.imagesFolder<< m_paramsForClustering.deltaForAngle<<m_paramsForClustering.deltaForKptsAngle<<m_paramsForClustering.clusterFolder;
    m_paramsForClustering.clusterType=eClusteringWithAngles;
    std :: string detectorName;
    fs["fdDetectorNames"]>>detectorName;


    if(detectorName=="Orb"){
        m_paramsForFeatureDetector.detectorName=eOrbFeatureMatcher;
    }else if(detectorName=="Akaze"){
        m_paramsForFeatureDetector.detectorName=eAkazeFeatureMatcher;
    }else if(detectorName=="Sift"){
        m_paramsForFeatureDetector.detectorName=eSiftFeatureMatcher;
    }else if(detectorName=="Surf"){
        m_paramsForFeatureDetector.detectorName=eSurfFeatureMatcher;
    }else {
        m_paramsForFeatureDetector.detectorName=eUnknownFeatureDetector;
    }


}
void ClusterUpdater::runFeatureDetector(int countOfThreads)
{
    FeatureDetector fd;
    fd.run(m_paramsForFeatureDetector);

    m_imagesYamlPath=fd.getImagesPaths();
    //std::cout << "Featur Detection is finished";
}
void ClusterUpdater::runClustering()
{
    if(m_imagesYamlPath.size()!=0){
    ClusterCreator cc(m_paramsForClustering,m_imagesYamlPath);
    //std::cout << "Clustering is done";
    }
}
*/

void ClusterUpdater::sendPath(const std::string Path)
{
    ClusterPathSender sender;
    sender.run(Path.c_str());
}
