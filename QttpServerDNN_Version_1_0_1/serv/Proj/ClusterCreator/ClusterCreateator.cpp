#include "ClusterCreateator.h"
#include <QString>

ClusterCreator::ClusterCreator(const ParametrsForClustering &Params)
{
    //m_clusterCreator=detectClusterCreatorType(Params.clusterType,Params.imagesFolder);
    if(createClusters(Params)==false){
        std :: cout << "Clustering Creation Failed !!!";
    }
    //infoAboutThis(Params);

}


Clustering* ClusterCreator::detectClusterCreatorType(const clusterCreatorType &type, cv::String imgPath)
{
    Clustering *clusterCreator;
    switch(type){
    case eClusteringWithAngles:
        clusterCreator= new ClusteringWithAngles(imgPath,imgPath);
        break;
    }
    return clusterCreator;
}
bool ClusterCreator:: createClusters(const ParametrsForClustering &Params){

    std::vector <cv::String> imageYamlNames,names,imgpath;
    cv::glob(Params.imagesFolder,imageYamlNames,true);
    //    cv::FileStorage fsR ("/home/admin/.ImgSearchInfo/infoFeatures.yaml",cv::FileStorage::READ);
    //    fsR["names"]>>names;
    //    fsR["paths"]>>imgpath;
    //    std::string path;
    //    for(int i = imgpath.size()-1 ; i >=0;--i){
    //        if(imgpath.at(i)==Params.imagesFolder){
    //            path=Params.imagesFolder+"_"+names.at(i)+"/";
    //            break;
    //        }
    //    }
    ClusteringWithAngles clusterCreator(Params.imagesFolder,Params.imagesFolder);
    int id=0;
    for (size_t i=0;i<imageYamlNames.size();++i){
        if(isFormatYaml(imageYamlNames.at(i))==true){
            if(isRightFile(imageYamlNames.at(i),Params.extractorName)){

                std::cout <<'\r'<<"Progress : "<<100*(i + 1)/imageYamlNames.size()<<"%"
                         << std::flush;
                clusterCreator.divideIntoParts(imageYamlNames.at(i),Params.deltaForAngle,Params.deltaForKptsAngle,id);
                id++;
            }
        }
    }
    std::cout << std::endl;
    clusterCreator.toYaml(Params.clusterFolder);
    return true;
}

bool ClusterCreator::isFormatYaml(std::string path)
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

void ClusterCreator::infoAboutThis(ParametrsForClustering Params)
{
    cv::FileStorage fsR ("/home/admin/.ImgSearchInfo/infoFeatures.yaml",cv::FileStorage::READ);

    std::vector <cv::String> detectorNames;
    std::vector < cv::String> names;
    std::vector <cv::String>paths;

    fsR["detectorname"]>>detectorNames;
    fsR["names"]>>names;
    fsR["paths"]>>paths;
    int position ;
    for(size_t i = 0;i<paths.size();++i){
        if(Params.extractorName==names.at(i)){
            position=i;
        }
    }

    std::stringstream ss;
    ss << Params.deltaForAngle;
    std::string str = ss.str();
    std::stringstream ss1;
    ss1 << Params.deltaForKptsAngle;
    std::string str1 = ss1.str();
    std::string name=names.at(position)+str+str1;

    std::vector <cv::String> namesClust,detectNames,clusterN;
    std::vector <cv::String> pathsClust;
    std::vector <cv::String> pathsImages;
    cv::FileStorage fsR1 ("/home/admin/.ImgSearchInfo/infoClusters.yaml",cv::FileStorage::READ);

    fsR1["clusterName"]>>clusterN;
    fsR1["detectorNames"]>>detectNames;
    fsR1["names"]>>namesClust;
    fsR1["pathsClust"]>>pathsClust;
    fsR1["pathsImages"]>>pathsImages;

    detectNames.push_back(detectorNames.at(position));
    namesClust.push_back(names.at(position));
    pathsClust.push_back(Params.clusterFolder);
    pathsImages.push_back(Params.imagesFolder);
    clusterN.push_back(name);

    cv::FileStorage fs ("//home/admin/.ImgSearchInfo/infoClusters.yaml",cv::FileStorage::WRITE);
    fs<<"clusterName"<<clusterN;
    fs<< "detectorNames"<<detectorNames;
    fs << "names" <<namesClust;
    fs << "pathsClust" <<pathsClust;
    fs << "pathsImages" <<pathsImages;

}

bool ClusterCreator::isRightFile(std::string path , std::string extractorName)
{

    if(path.find(extractorName)!=std::string::npos){
        return true;
    }
    return false;
    //    int pos=path.find_last_of('.')-1;
    //    for(int i = extractorName.size()-1;i>=0;--i){
    //        if(extractorName.at(i)!=path.at(pos)){
    //        return false;
    //        }
    //        pos--;
    //    }
    //    return true;
}
