#include "Loader.h"
#include <QDir>

Loader::Loader()
{

}
std::vector <QString> Loader::getInfo()
{
    return m_names;
}
bool Loader::loadFile(QString name)
{
    qDebug() << "Loading.. " ;
    std::string path=name.toUtf8().constData();
    //cv::String pathWConf=PathConfig(path);
    InfoProvider newIProv;
	newIProv=newIProv.load(path);//= new InfoProvider(path);
    //ClusteringInfoProvider *newProv= new ClusteringInfoProvider(pathWConf);l
//    std ::cout << " Experimental " << newIProv.getImagePath(14);
    m_names.push_back(name);
    m_loades.push_back(newIProv);
    true;
}

bool Loader::updateFiles(QString name)
{
    std::string path=name.toUtf8().constData();
    //cv::String pathWConf=PathConfig(path);
    if(m_loades.size()!=0){
	m_loades.at(0)=m_loades.at(0).update(path);
    }    

//    std::vector <ClusteringInfoProvider *>::iterator it;
//    it=m_loades.begin()+position;
//    m_loades.erase(it);
//    std::vector <QString> ::iterator it1;
//    it1=m_names.begin()+position;
//    m_names.erase(it1);
//    loadFile(name);
    //qDebug() << "position"<< position;
    //m_loades.at(position)->update(pathWConf);
   // m_loades.at(position)->printImageName_DeBug();
}
std::vector<std::string> Loader::searchImage(QString name,QString ClustName)
{
    qDebug()<<"Finder: Image searching is starting";
    qDebug()<< "SizeOfLoads " <<m_loades.size(); 
    if(m_loades.size()!=0){

        int position;
        for(int i =0; i<m_names.size();++i){
            if(m_names.at(i).contains(ClustName)){
                position=i;
                break;
            }
        }
        qDebug() << "Current Position"<< position<<name ;
        std::string path=name.toUtf8().constData();
        //cv::Mat img =cv::imread(path);
        //qDebug() << "imageSize"<<img.rows<<"X"<<img.cols ;

        std::vector <std::string> fullPath;
	Compare finder(m_loades.at(position));
	finder.getSimillar(path);
        //FindImage finder(m_loades.at(position));
        //finder.compare(img);
        //std ::string _simillarImg=finder.onePic();
        //cv::FileStorage _fs("/root/.info"+path+".yaml",cv::FileStorage::WRITE);
        //std :: cout <<"root/.info"+path+".yaml"<<std :: endl;
        //_fs << "Image"<<_simillarImg;
//        std::string a=finder.onePic();
//        qDebug() << "Current img path" << QString::fromStdString(a);
//std :: cout << std :: endl << " ok beforelist ";
  //      std::vector <std::string> similarImg= finder.getSimilarImgPathsList();
    //    std::vector <float> precent = finder.precentOfSimilarityList();
      //  std :: cout << std :: endl << " ok afterlist";
//        for ( int i =0 ; i < precent.size();++i){
//            if(precent.at(i)!=0){
//                qDebug() << QString::fromStdString(similarImg.at(i));
//                std::stringstream convert ;
//                convert<< precent.at(i);
//               std::string precentstr;
//                convert >> precentstr;
//                fullPath.push_back(precentstr+":"+similarImg.at(i)+":");
//            }
//        }
//                std::vector < QString> paths;
//                for (int i =0 ; i <fullPath.size();++i){
//                    QString path1=QString::fromUtf8(fullPath.c_str());
//                    paths.push_back(path1);
//                }

	fullPath.push_back("1:OK");
        return fullPath;
    }
    //    else{
    //        qDebug()<< "doesn't exist loaded file ";
    //        return "";
    //    }
}
std::vector<std::string> Loader::similarImgs(QString name ,QString ClustName)
{

        int position=-1;
        for(int i =0; i<m_names.size();++i){
            if(m_names.at(i).contains(ClustName)){
                position=i;
                break;
            }
        }
        if(position==-1){
           // cv::FileStorage fs ("/home/admin/.ImgSearchInfo/infoClusters.yaml",cv::FileStorage::READ);
            //std::vector <cv::String> cn,cp;
            //std::vector <std::string > err;
           // fs["clusterName"]>>cn;
           // fs["pathsClust"]>>cp;
            //int pos=-1;
            //qDebug()<<cn.size();
            //for(int i = 0 ; i < cn.size();++i){
            //    if(QString::fromStdString(cn.at(i)).contains(ClustName)){
            //        pos=i;
            //        break;
            //    }
            //}
            //qDebug()<<"pos value :"<<pos;
            //if(pos==-1){
            //    qDebug()<< "Cluster name was not founded";
            //    return err;
            //}
            //loadFile(QString::fromStdString(cp.at(pos)));
            //position=m_loades.size()-1;
        }



        QDir recoredDir(name);
        QStringList allFiles = recoredDir.entryList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden
                                                    | QDir::AllDirs | QDir::Files, QDir::DirsFirst);
        std::vector <std::string> fullPath;
        for(int i = 0;i<allFiles.size();++i){
            qDebug()<<i << "of" << allFiles.size()-1;
            std::string path = name.toStdString()+allFiles.at(i).toStdString();

           // cv::Mat img =cv::imread(path);

           // FindImage finder(m_loades.at(position));
           // finder.compare(img);

            //std::vector <std::string> similarImg= finder.getSimilarImgPathsList();
           // std::string p=finder.onePic();
           // std::vector <float> precent = finder.precentOfSimilarityList();
           // float max=0;
           // int pos;
//            for ( int i =0; i<precent.size();++i ){
//                if(precent.at(i)>max){
//                    max=precent.at(i);
//                    pos=i;
//                    if(max==100){
//                        break;
//                    }
//                }
//            }

            //fullPath.push_back(p+":");
        }
        return fullPath;

}
//cv::String Loader::PathConfig(std::string path)
//{
 //   if(path.at(path.length()-1)=='/'){
 //       path.at(path.length()-1)==NULL;
 //   }
 //   return path;
//}
