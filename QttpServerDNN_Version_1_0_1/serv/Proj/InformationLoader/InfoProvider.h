#ifndef INFO_PROVIDER_H
#define INFO_PROVIDER_H

#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <map>
#include <QTime>
class InfoProvider {

public:
	struct Info {
		int id;
		std::vector<float> featVec;
		std::string imgPath;
	};
public:
	InfoProvider();
	InfoProvider & load(const std::string& path);
	InfoProvider & update(const std::string& path);
	std::vector<float> getFeatureVector(int id);
	std::string getImagePath(int id);
	int getImageCount();
 
        static std::vector<float> readFeatureFromFile(const std::string & path);
private: 
	void out_file();
private: 
	bool m_isLoaded;
	std:: vector <Info> m_impl;
	int m_countOfImages;
};

#endif // INFO_PROVIDER
