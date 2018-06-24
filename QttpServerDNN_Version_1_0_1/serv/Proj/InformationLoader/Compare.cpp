#include "Compare.h"
#include <fstream>
#include <string>
#include <sstream>
#include <QProcess> 
#include <QString>
#include <QStringList>


#define MIN_VALUE 100000

Compare::Compare(InfoProvider prov):m_impl(prov)
{
	
}

void Compare::getSimillar(const std::string & path){
//	 std::cout << m_impl.getImagePath(14);
//	std::cout << "Working...." <<std::endl;
	std::string pathForRead = path+".yaml";
	std::cout <<"Path For Reading " <<  pathForRead << std::endl;
        cv::FileStorage fs(pathForRead , cv::FileStorage::READ);
        fs["desc"] >> m_desc;
        fs["kpts"] >> m_kpts;
	std::cout <<"size of descc "  << m_desc.size() <<std::endl;
	m_generalImg = cv::imread(path.substr(23,path.length()-6));
	std::vector<std::pair<int,std::string>> sor;
	std::vector<float> coeff;
	int min=MIN_VALUE;
	int simillarId;
	std::string simillarPath;

for(int i =0 ; i < 5 ; ++i){
	std::cout << " ENDD " << i << std::endl;
	std::string _path;
	if(i==0){
		_path=path;
	}
	else{	
		std::stringstream ss;
		ss << i ; 
		std::string num;
		ss >> num; 
		_path=path.substr(0,path.length()-6)+num+".pngfe.txt";
	}
	
        std::vector<float> currVec=readFeatureFromFile(_path);
     
        int size = m_impl.getImageCount();
     
        //int min=MIN_VALUE;
       
       
	std::vector<std::string> sor1;
		
        for(int k =0 ; k <size;++k){
		std::string pt =  m_impl.getImagePath(k);
		//sor1.push_back( m_impl.getImagePath(i));
                std::vector<float> vec=m_impl.getFeatureVector(k);
		
//            std::cout << "Vec Size " << vec.size()<<std::endl;
//            std::cout << "Min Val " <<min <<std::endl;
		int pos=0 ;
		float val =EuclideanDistance<float>(currVec,vec);
		if(val < min){
			min = val;
			simillarPath=m_impl.getImagePath(k);			
		}
		//if(val <4){
		/*	bool are = false;
			for(int j = 0 ; j < sor.size();++j){
				std::cout <<"new" <<  j<<std::endl; 
				if(sor.at(j).second==pt){//.isubstr(pt.find_last_of("/")+1,pt.find_last_of("_")-pt.find_last_of("/")-1)){
					sor.at(j).first++;
					are=true;
					coeff.at(j)+=val;
					break;
				}
			}
			if(are == false){
				std::pair<int,std::string> _s(1,pt);//.substr(pt.find_last_of("/")+1,pt.find_last_of("_")-pt.find_last_of("/")-1));
				sor.push_back(_s);
				coeff.push_back(val);
			}
		//}
		/*std::cout << " Val " << val <<std::endl	;
		while( sor.at(pos).first<val){
			pos++;			
		}
		std::vector<std::pair<float ,std::string>>::iterator it;
		it = sor.begin()+pos;
		std::pair<float,std::string> p(val,m_impl.getImagePath(i));
		sor.insert(it,p);
                /*if(EuclideanDistance<float>(currVec,vec)<min && EuclideanDistance<float>(currVec,vec)<30){

                        min=EuclideanDistance<float>(currVec,vec);
                        simillarId=i;
                        simillarPath=m_impl.getImagePath(i);
                }*/
        }
	std::cout << " After Finding; " <<std::endl;
	}
	std::cout << " HEre " << std::endl;
//      std::cout <<"Similar Path " <<  simillarPath<<std::endl;
	std::string constStr="/home/ubuntu/.imagesinfo/accuaracy1.log";
        std::string constStr1="/home/ubuntu/.imagesinfo/accuracy.log";
	std::string simillarPathOut =path.substr(0,path.length()-6)+".txt";
//      std::cout<<"Path Out "<<simillarPathOut << std::endl ;
        std::ofstream out(simillarPathOut.c_str());
	std::ofstream o8(constStr.c_str());
	std::ofstream o9(constStr1.c_str());
	int max = 0;
	int _pos=-1;
	for(int i = 0 ; i< sor.size();++i){
		if(sor.at(i).first>max){
			max =sor.at(i).first;
			_pos=i;
		}
	}
	std::cout << "after sor "<<std::endl; 
	for(int i = 0 ; i<sor.size();++i){
		std::stringstream ss;
		ss<<sor.at(i).first;
		std::string num;
		ss>>num;
		o9 << num+ " " + sor.at(i).second << "\n";
	}
	std::cout << "after sor1" << std::endl ;
	for(int i = 0 ;i <coeff.size();++i){
		std::stringstream ss;
                ss<<coeff.at(i)/sor.at(i).first;
                std::string num;
                ss>>num;
                o8 << num+ " " + sor.at(i).second << "\n";
	}
	o8.close();
	o9.close();
	std::cout << "bbbb " << std::endl;
	//std::cout << sor.at(_pos).second<<std::endl;
	std::vector<std::string> strs;
	//for(int i = 0 ; i < sor.size();++i){
	//	strs.push_back(sor.at(i).second);
	//}
	std::cout << "aaaa " <<std::endl;
	//std::string last= getSimillarWithNear(strs);
	
	//std::cout << " Path : /home/ubuntu/trainData/"+last <<std::endl;
	//if(last.length()!=0){
        //	out << last;
	//}
	//else{
	std::cout << "position val " << _pos << std::endl;
	out << simillarPath;
	//}
        out.close();
	

}
std::string Compare::getSimillarWithNear(const std::vector<std::string> & vecStr){
	std::vector<std::vector<std::pair<int , std::vector <uchar>>>> clus(100000);
	for(size_t i =0 ; i<vecStr.size(); ++i){
        	std::cout << i << " of " <<vecStr.size();
        	std::string pathForRead = "/home/ubuntu/trainData/"+vecStr.at(i)+".yaml";
	        std::vector <cv::KeyPoint > kpts;
        	std::vector <std::vector <uchar>> featuresFinal;
	        cv::FileStorage fs(pathForRead , cv::FileStorage::READ);
       		fs["desc"] >> featuresFinal;
	        fs["kpts"] >> kpts;
		for (size_t j = 0 ; j < featuresFinal.size() ; ++j){
			int sum =0 ; 
			for ( size_t k = 0 ; k < featuresFinal.at(j).size();++k){
				sum+=int(featuresFinal.at(j).at(k)*featuresFinal.at(j).at(k)); 
			}
			sum = std::sqrt(sum);
			//std::cout << sum << std::endl;
			clus.at(sum/10).push_back(std::pair<int , std::vector <uchar>>(i,featuresFinal.at(j)));
		}
	}
	std::vector <int>  histogram(vecStr.size());
	for(size_t i = 0 ; i < histogram.size(); ++i){
		histogram.at(i)=0;
	}
	std::cout <<"size of descc "  << m_desc.size() <<std::endl; 
	for(size_t i = 0 ; i < m_desc.size();++i){
		int pos = 0 ;
		for ( size_t j = 0 ; j < m_desc.at(i).size();++j){
                        pos+=int(m_desc.at(i).at(j)*m_desc.at(i).at(j));
                }
                pos = std::sqrt(pos)/10;
		std::cout << "Position :  " << pos  << "count of Clusts " << clus.at(pos).size()<< std::endl;
		int min = 999999;
		int currNum=-1 ; 
		for(size_t j = 0 ; j< clus.at(pos).size() ; ++j){
			
			if(int(EuclideanDistance<uchar>(m_desc.at(i),clus.at(pos).at(j).second))<min){
				min = int(EuclideanDistance<uchar>(m_desc.at(i),clus.at(pos).at(j).second));
				currNum = clus.at(pos).at(j).first ; 	
			}
		}
		if(currNum != -1){
			histogram.at(currNum)++;
		}
	}
	int max_ll = 0;
	int pos_ll =-1;
	for(size_t i = 0 ; i < histogram.size();++i){
		std::cout << histogram.at(i) <<" " <<vecStr.at(i) << std::endl ;
		if(histogram.at(i)>max_ll){
			max_ll=histogram.at(i);
			pos_ll=i;
		}
	}
	if(pos_ll!=-1){
		return vecStr.at(pos_ll);
	}
	return std::string();
	

}

template<class T>
T Compare::EuclideanDistance(const std::vector<T>& v1, const std::vector<T>& v2)
{
	if (v1.size() != v2.size()) {
		return T();
	}
	else {
		T EuclidVal=0; 
		for (size_t i = 0; i < v1.size(); ++i) {
			EuclidVal += ((v1.at(i) - v2.at(i))*(v1.at(i) - v2.at(i)));
		}
		return EuclidVal;
	}
}

std::vector<float> Compare::readFeatureFromFile(const std::string & path){
        std::vector< float > reVal;
        std::ifstream reader;
        reader.open(path.c_str());

        while(!reader.eof()){
                std::string ValStr;
                reader>> ValStr;
                std::stringstream convert;
                convert <<ValStr;
                float num ;
                convert>> num ;
                reVal.push_back(num);
        }

        return reVal;

}


std::string Compare::getSimillarImg(const std::vector<std::string> & vecStr){
	//std::vector<std::pair<int , std::vector <float>> clus(100000);
	std::cout << "Now Working getSimillarImg(const std::vector<std::string> & vecStr)" <<std::endl;
   for(size_t i =0 ; i<vecStr.size(); ++i){
	std::cout << i << " of " <<vecStr.size();
	std::string pathForRead = "/home/ubuntu/trainData/"+vecStr.at(i)+".yaml";
	std::vector <cv::KeyPoint > kpts;
	std::vector <std::vector <float>> featuresFinal;
	cv::FileStorage fs(pathForRead , cv::FileStorage::READ);
	fs["desc"] >> featuresFinal;
	fs["kpts"] >> kpts;
	
	if (kpts.size() != 0) {
		cv::Mat desc = cv::Mat::zeros(featuresFinal.size(), featuresFinal.at(0).size(), CV_8U);
		cv::Mat desco = cv::Mat::zeros(m_desc.size(), m_desc.at(0).size(), CV_8U);
		for (int i = 0; i < featuresFinal.size(); i++) {
			for (int j = 0; j < featuresFinal.at(i).size(); j++) {
				desc.at<uchar>(i, j) = featuresFinal.at(i).at(j);
			}
		}
		 for (int i = 0; i < m_desc.size(); i++) {
                        for (int j = 0; j < m_desc.at(i).size(); j++) {
                                desco.at<uchar>(i, j) = m_desc.at(i).at(j);
                        }
                }
		std::cout << " after making a mats " << std :: endl ;
		cv::BFMatcher matcher(cv::NORM_HAMMING);
		std::vector< std::vector<cv::DMatch> > nn_matches;
		//std::cout << m_desc.cols << " " << desc.cols; 
		matcher.knnMatch(desco, desc, nn_matches, 2);
		std::cout << " after Matching " << std::endl;

		std::vector<cv::KeyPoint> matched1, matched2;

		for (size_t i = 0; i < nn_matches.size(); i++) {
			cv::DMatch first = nn_matches[i][0];
			float dist1 = nn_matches[i][0].distance;
			float dist2 = nn_matches[i][1].distance;
			if (dist1 < 0.9 * dist2) {
				matched1.push_back(m_kpts[first.queryIdx]);
				matched2.push_back(kpts[first.trainIdx]);
			}
		}

		std::vector<cv::Point2f> pt1, pt2;
		for (int i = 0; i < matched1.size(); ++i) {
			pt1.push_back(matched1[i].pt);
			pt2.push_back(matched2[i].pt);
		}
		if (pt1.size() != 0 && pt2.size() != 0) {
			cv::Mat M = cv::findHomography(pt1, pt2, cv::RANSAC);
			if (M.cols == 3 || M.rows == 3) {


				std::vector<cv::Point2f> vec, vec1;

				cv::Point2f a(0, 0), b(0, m_generalImg.cols), c(m_generalImg.rows, m_generalImg.cols), d(m_generalImg.rows, 0);
				vec.push_back(a);
				vec.push_back(b);
				vec.push_back(c);
				vec.push_back(d);

				cv::perspectiveTransform(vec, vec1, M);

				if(cv::isContourConvex(vec1)){
					return vecStr.at(i);
				}

				}
			}
		}
	}
	return std::string();
}
