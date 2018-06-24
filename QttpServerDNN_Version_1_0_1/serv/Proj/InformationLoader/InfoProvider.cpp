#include "InfoProvider.h" 
#include <fstream>
#include <ctime>
#include <QString>
#include <QDebug>
InfoProvider:: InfoProvider(){
	m_countOfImages=0;
}


InfoProvider& InfoProvider::load(const std::string & path){
	
	std::string mapFolder=path+"/mapping.map";
	std::ifstream mapping;
        mapping.open(mapFolder.c_str());
	
	std::vector<int> ids;
	std::vector<std::string> paths;
        while(!mapping.eof()){
        	std::string mapStr;
        	mapping>> mapStr;	
		int posit=mapStr.find_first_of(':');
	        if(posit>=0 && posit<=mapStr.length()){
            	    std::string number=mapStr.substr(0,posit);
                    std::string pathr=mapStr.substr(posit+1,mapStr.length()-posit);
		    std::stringstream convert;
                    convert << number;
           	    int num ;
          	    convert>> num ;
    	            ids.push_back(num);
                    paths.push_back(pathr);
       	  	}
   	 }

	//std::cout << "size " << paths.size() << " itd " << ids.size()<<std::endl;
	m_countOfImages =paths.size();
	for(int i = 0 ; i<m_countOfImages;++i){
		std::cout << i << " from " << paths.size()<<std::endl;	
		InfoProvider::Info curr;
		curr.id=ids.at(i);
		curr.imgPath=paths.at(i);
		std::cout << paths.at(i)+".txt"<< std::endl;
		curr.featVec=readFeatureFromFile(paths.at(i)+".txt");	
		m_impl.push_back(curr);
	}
	
	m_isLoaded=true;
	//out_file();
	std::string path_out = "/home/ubuntu/.imagesinfo/LastLoadTime.log";
        //qDebug() << path;
        std::ofstream out(path_out.c_str(),std::ofstream::app);
	QString ti = QTime::currentTime().toString();
	out << ti.toStdString();
	return *this;

	//std::cout << m_impl.at(14).id << " " <<m_impl.at(14).imgPath<<std::endl;
	//for(int i = 0; i<128; ++i){		std::cout <<m_impl.at(14).featVec.at(i) <<std::endl;
	//}
}

InfoProvider& InfoProvider::update(const std::string & path){
	std::cout << "Updating : "<< path  << std ::endl;
	int posit=path.find_first_of(':');
	std::string number=path.substr(0,posit);
        std::string pathr=path.substr(posit+1,path.length()-posit);
        std::stringstream convert;
        convert << number;
        int num ;
        convert>> num ;
	InfoProvider::Info curr;
        curr.id=num;
        curr.imgPath=pathr;
        curr.featVec=readFeatureFromFile(pathr+".txt");
	m_countOfImages++;
	m_impl.push_back(curr);
/*        std::vector<int> ids;
        std::vector<std::string> paths;
        while(!mapping.eof()){
                std::string mapStr;
                mapping>> mapStr;
                int posit=mapStr.find_first_of(':');
                if(posit>=0 && posit<=mapStr.length()){
                    std::string number=mapStr.substr(0,posit);
                    std::string pathr=mapStr.substr(posit+1,mapStr.length()-posit);
                    std::stringstream convert;
                    convert << number;
                    int num ;
                    convert>> num ;
                    ids.push_back(num);
                    paths.push_back(pathr);
                }
         }
	std::cout  << "CountOfImages " << m_countOfImages<< " "  << paths.size()<<std::endl;
	for(;m_countOfImages <paths.size() ; m_countOfImages++){ 
		InfoProvider::Info curr;
                curr.id=ids.at(m_countOfImages);
        	curr.imgPath=paths.at(m_countOfImages);
        	curr.featVec=readFeatureFromFile(paths.at(m_countOfImages)+".txt");
        	m_impl.push_back(curr);
	}*/
	std::cout << "Updating Finished ; " <<std::endl; 
	//out_file();
	return *this;
}

std::vector<float> InfoProvider:: getFeatureVector(int id){
	if(id < m_countOfImages){
		return m_impl.at(id).featVec;
	}
}

std::string InfoProvider::getImagePath(int id){
	if(id < m_countOfImages){
		return m_impl.at(id).imgPath;
	}
}

std::vector<float> InfoProvider::readFeatureFromFile(const std::string & path){
	std::vector< float > reVal;
	std::ifstream reader;
        reader.open(path.c_str());
//	std::cout << "Path" << path <<std::endl;int i =0;
        while(!reader.eof()){
                std::string ValStr;
                reader>> ValStr;
		std::stringstream convert;
                convert <<ValStr;
		
                float num;
                convert>> num ;
		reVal.push_back(num);
//		std::cout << ValStr<<" " << num<<" " <<reVal.at(i)<<std::endl;

}


	return reVal;

}

int InfoProvider::getImageCount(){
	std::cout << " Getting count of images " ;
	return m_countOfImages;
}

void  InfoProvider::out_file(){
	std::string path = "/home/ubuntu/.imagesinfo/InfoProvider_out.log";
	//qDebug() << path;
	std::ofstream out(path.c_str(),std::ofstream::app);
	QString ti = QTime::currentTime().toString();
	
	if(m_isLoaded==true){
		out << "Loading ";
	}
	else{
		out << "Updateing ";
	}
	out<< "Time \n"; 
	out << ti.toStdString();

	for(int i = 0 ; i <m_impl.size();++i){
		out<< m_impl.at(i).imgPath+"\n";
	} 
	out << "Feat \n";
	for(int i = 0 ; i <m_impl.size();++i){
		for(int j = 0;j <  m_impl.at(i).featVec.size();++j){
                      out<< m_impl.at(i).featVec.at(j);
		}
	out << "\n";
        }
	out.close();
	
}

