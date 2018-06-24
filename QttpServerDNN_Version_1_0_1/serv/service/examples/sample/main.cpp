#include <qttpserver>
#include <swagger.h>
#include <QtCore>
#include <QProcess>
#include <QTest>
//#include <opencv2/core/core.hpp>
//#include <opencv2/highgui/highgui.hpp>
//#include <opencv2/imgproc/imgproc.hpp>
#include <QDebug>
#include <QTime>
#include <QDate>
#include <time.h>
#include <fstream>
#include <QString>

#include <QJsonDocument>
using namespace std;
using namespace qttp;
using namespace native::http;


class QueryImageFromTrainData : public Action
{
public:
    QueryImageFromTrainData() : Action()
    {
    }

    const char* getName() const
    {
        return "queryImageFromTrainData";
    }

    QStringList getTags() const
    {
        static const QStringList list = { "tag1", "tag2" };
        return list;
    }

    std::vector<Input> getInputs() const
    {
        static const std::vector<Input> list =
        {
            Input("someinput"),
            RequiredInput("reqinput"),
            Input("options", "some options", { "selectone", "selectanother" })
        };
        return list;
    }

    void onGet(HttpData& data)
    {
	qDebug() << "onGet ";
        QFile receivedFile("/home/ubuntu/trainData/31_5_2018_19_56_38_1186278907_kZYLgbwvWcUZI7cRa4XTLqFyJzS2-LDqlUiFVyPGtCz3OSrl-LDqlUiGRuySCEzKNY0U-LDrlPofd7mWp6ynMTtU.png");
        receivedFile.open(QIODevice::ReadOnly);
        QByteArray arr = receivedFile.readAll();
        receivedFile.close();
QString	tag = "kZYLgbwvWcUZI7cRa4XTLqFyJzS2-LDqlUiFVyPGtCz3OSrl-LDqlUiGRuySCEzKNY0U-LDrlPofd7mWp6ynMTtU.png";
        //data.getResponse().getJson()["data"] = QSTR("GET ok");
        //data.getResponse().getJson()["vahag"] = QSTR("vahag avagyan");
        //data.getResponse().finish(arr);
       // data.getResponse().getJson()["vahag"] = QSTR("vahag avagyan");
        QJsonObject object
        {
            {"property1", 1},
            {"tag", tag},
            {"img3", QString(arr.toBase64())}
        };
        data.getResponse().setJson(object);
        data.getResponse().finish();


    }

    void onPost(HttpData& data)
    {


        qDebug() << "onPost";
	qDebug() <<"Size of Image Body " <<  data.getRequest().getBody().size();
	if(data.getRequest().getBody().size()==0){
		data.getResponse().getJson()["data"] = QSTR("Image size()=0");
	}else{
	//qDebug() << data.getRequest().getBody();
        QString randomName = "/home/ubuntu/querryData/" + QDate::currentDate().toString("d_M_yyyy") + "_" + QTime::currentTime().toString("h_mm_ss") + "_" + QString::number(qrand());
        QFile receivedFile(randomName + ".png");
        receivedFile.open(QIODevice::WriteOnly);
	qDebug() <<"Size of Image Body " <<  data.getRequest().getBody().size();
        receivedFile.write(data.getRequest().getBody());
        receivedFile.close();
	qDebug() << "image is already saved : " ;	
	//std::string simillarImg = randomName.toStdString() + ".png";

    QDir directory("/ooot/trainDataImages");
	QStringList images = directory.entryList(QStringList() << "*.png" ,QDir::Files);

    //new added
    
    QString file="/home/ubuntu/bin/Querry";
    QStringList params;
    QProcess *partExtraction = new QProcess();
    QString fl = "/home/ubuntu/bin/extractorFeat";
    QStringList arguments = QStringList()<<  randomName+".png";
    partExtraction->start(fl,arguments);
    QProcess *PyFE = new QProcess();
    //QString pyFile="/home/ubuntu/pythonnn/PrintdaryNN/fe.py";
    QString command= "python3.6";
    QString path= "/home/ubuntu/pythonnn/PrintdaryNN/";
    QStringList pythonCommandArguments = QStringList() << "runner" <<  randomName+".png" <<"/home/ubuntu/DNN/model_imagenet_and_custom_dataset.pt"
 	<<"/home/ubuntu/.imagesinfo"+randomName + ".pngfe.txt";

    PyFE->setWorkingDirectory(path);	
    PyFE->setProgram("/bin/bash");
	
    PyFE->setArguments(pythonCommandArguments);
    PyFE->start();


    PyFE->waitForFinished(-1);
    
    qDebug () <<"Process Error" <<QTime::currentTime()<<   PyFE->error();
    PyFE->close();
    //for(int i = 0 ; i <1 ;++i){
	QProcess *querryImg=new QProcess();
	QString smth; 
	/*if(i!=0){
		std::stringstream ss;
		std::string num;
		ss << i ;
		ss >> num;
		smth="/home/ubuntu/.imagesinfo"+randomName + ".png"+QString::fromStdString(num)+".pngfe.txt";
        	params << smth << "train";
	}
	else{
		smth="/home/ubuntu/.imagesinfo"+randomName + ".pngfe.txt";
		params << smth << "train";
	}*/
	smth="/home/ubuntu/.imagesinfo"+randomName + ".pngfe.txt";
        params << smth << "train";
        querryImg->start(file,params);    

    qDebug() << "Imageyy Path " <<smth;

 //   std::ifstream fstr("/home/ubuntu/.imagesinfo"+randomName.toStdString() + ".pngfe.txt");
  //  std::string str;
   // while(!fstr.eof()) {
//	    fstr >> str;
//	    qDebug() <<"File content" <<  QString::fromStdString(str);
 //   }

    //params << "/home/ubuntu/.imagesinfo"+randomName + ".pngfe.txt" << "train";
    qDebug() << "after Python" ;
    if(querryImg->isReadable()){
        qDebug()<< "Readable " ;
    }
    if(querryImg->waitForStarted()){
        qDebug()<<"Program Starting " ;
    }
    if(querryImg->waitForFinished(-1)){
        qDebug() << "Program has already Finished:";
    }
    qDebug() << "Program has already Finished:" ;
    

    std :: string simillarImg,pathpy= "/home/ubuntu/.imagesinfo"+randomName.toStdString() + ".png.txt";
    qDebug() << " Reading "<<QString::fromStdString(simillarImg);
    std::ifstream reader;
	reader.open(pathpy.c_str());

	while (!reader.eof()) {
		reader >> simillarImg;
	}

// append
    //std::string pathInfo="/home/ubuntu/.imagesinfo/imgs.txt";
    //std::ofstream outInfo;
    //outInfo.open(pathInfo.c_str(),std::ofstream::app);
    //std::string strInfo = randomName.toStdString()+".png:"+simillarImg +"\n";
    //outInfo << strInfo;    
    qDebug() << " Similar Img Path "<<QString::fromStdString(simillarImg);
    if (simillarImg.find("rotated") != std::string::npos || simillarImg.find("resized") != std::string::npos) {
	std::cout <<"pathh " << simillarImg << std::endl ; 	
	int posOf_=simillarImg.rfind("_");
	std::string format = simillarImg.substr(simillarImg.rfind("."),simillarImg.length()-simillarImg.rfind("."));
	simillarImg= simillarImg.substr(0,posOf_);
	std::cout <<" path  "<<simillarImg << std::endl;
    }
//	simillarImg= "/home/ubuntu/trainData/"+simillarImg;
    if(simillarImg.substr(simillarImg.length()-4,4)=="HEIC"){
	simillarImg+=".png";
	}
    if( simillarImg.length()!=0){
        //int imageIndex = qrand()%images.size();
        QString fileName1 = QString::fromStdString(simillarImg);
        //QString fileName = images[imageIndex];
        QString tag = fileName1.split("_").last().split(".").first();
	//tag = "kZYLgbwvWcUZI7cRa4XTLqFyJzS2-LE-TYZx8zstkjgEQAl4-LE-TanvC4n8-3QiOphN-LE-Tfb1E4uW9TiKNe3G";
        qDebug()<< "tag " << tag;
	qDebug()<< "fileName" << fileName1;
        	data.getResponse().getJson()["data"] = QSTR("POST ok");
        	data.getResponse().getJson()["tag"] = tag;//QSTR("POST ok");

        QFile receivedFile(fileName1);
        if(receivedFile.exists()){
	qDebug() << "file exists";
	}
	receivedFile.open(QIODevice::ReadOnly);
		QByteArray arr = receivedFile.readAll();
		receivedFile.close();
        //qDebug()<<"size " <<arr;
	std::cout <<"Image BArray Size" <<  arr.size();

//	QString tag = "aaa " tag = "kZYLgbwvWcUZI7cRa4XTLqFyJzS2-LE-TYZx8zstkjgEQAl4-LE-TanvC4n8-3QiOphN-LE-Tfb1E4uW9TiKNe3G";
        QJsonObject object
		{
			//{"data", "post ok"},
			{"tag", tag}
			//{"property2", 2},
			//{"imageBase64", QString(arr.toBase64())}
		};
//		data.getResponse().getJson()["data"] = QSTR("llll");

		data.getResponse().setJson(object);
}		
	 else{
        	data.getResponse().getJson()["data"] = QSTR("POST No Image found");
	}
}
        data.getResponse().finish();
	qDebug() << "Json Finished " ;	
    }

    void onPut(HttpData& data)
    {

        data.getResponse().getJson()["data"] = QSTR("PUT ok");
    }

    void onPatch(HttpData& data)
    {
        data.getResponse().getJson()["data"] = QSTR("PATCH ok");
    }
};
class AddImageIntoTrainData : public Action
{
public:
    AddImageIntoTrainData() : Action()
    {
    }

    const char* getName() const
    {
        return "addImageIntoTrainData";
    }

    QStringList getTags() const
    {
        static const QStringList list = { "tag1", "tag2" };
        return list;
    }

    std::vector<Input> getInputs() const
    {
        static const std::vector<Input> list =
        {
            Input("someinput"),
            RequiredInput("reqinput"),
            Input("options", "some options", { "selectone", "selectanother" })
        };
        return list;
    }

    void onGet(HttpData& data)
    {
        QFile receivedFile("voice.jpg");
        receivedFile.open(QIODevice::ReadOnly);
        QByteArray arr = receivedFile.readAll();
        receivedFile.close();

        //data.getResponse().getJson()["data"] = QSTR("GET ok");
        //data.getResponse().getJson()["vahag"] = QSTR("vahag avagyan");
        //data.getResponse().finish(arr);
       // data.getResponse().getJson()["vahag"] = QSTR("vahag avagyan");
        QJsonObject object
        {
            {"property1", 1},
            {"property2", 2},
            {"property3", QString(arr.toBase64())}
        };
        data.getResponse().setJson(object);
       // data.getResponse().finish(arr);


    }

    void onPost(HttpData& data)
    {
        qDebug() << "onPost TrainData";
        QString tag = data.getRequest().getJson()["tag"].toString();
	qDebug() <<"tag " <<  tag ; 
        QString randomName = "/home/ubuntu/trainData/" + QDate::currentDate().toString("d_M_yyyy") + "_" + QTime::currentTime().toString("h_mm_ss") + "_" + QString::number(qrand())+"_" + tag;
	
        qDebug() << "TrainData New file Created : " << randomName;



        QFile receivedFile(randomName + ".png");

        receivedFile.open(QIODevice::WriteOnly);
        receivedFile.write(data.getRequest().getBody());
        receivedFile.close();

	
        qDebug() << "TrainData New file stored : " << randomName;
	QProcess *PyFE = new QProcess();
    //QString pyFile="/home/ubuntu/pythonnn/PrintdaryNN/fe.py";
        QString command= "python3.6";
        QString path= "/home/ubuntu/pythonnn/PrintdaryNN/";
        QStringList pythonCommandArguments = QStringList() << "runnerForOne" <<  randomName+".png" <<"/home/ubuntu/DNN/model_imagenet_and_custom_dataset.pt"
        <<"/home/ubuntu/.imagesinfo"+randomName + ".pngfe.txt";

        PyFE->setWorkingDirectory(path);
        PyFE->setProgram("/bin/bash");

        PyFE->setArguments(pythonCommandArguments);
        PyFE->start();


        PyFE->waitForFinished(-1);

        QProcess *addImage=new QProcess();
        QString file="/home/ubuntu/bin/addImage";
        QStringList params;
        params << randomName + ".png";
        addImage->start(file,params);
        addImage->waitForFinished();

        data.getResponse().getJson()["data"] = QSTR("POST ok");
        data.getResponse().finish();	
    }

    void onPut(HttpData& data)
    {
        data.getResponse().getJson()["data"] = QSTR("PUT ok");
    }

    void onPatch(HttpData& data)
    {
        data.getResponse().getJson()["data"] = QSTR("PATCH ok");
    }
};

class Another : public Action
{
public:
    Another() : Action()
    {
    }

    const char* getName() const
    {
        return "another";
    }

    QStringList getTags() const
    {
        return { "tag1", "tag2" };
    }

    std::vector<Input> getInputs() const
    {
        return {
            Input("someinput"),
                    RequiredInput("reqinput"),
                    Input("options", "someoptions", { "selectone", "selectanother" })
        };
    }

    std::set<qttp::HttpPath> getRoutes() const
    {
        static const QString route = "/another";
        return {
            { HttpMethod::GET, route },
            { HttpMethod::POST, route }
        };
    }

    void onGet(HttpData& data)
    {
        data.getResponse().getJson()["data"] = QSTR("GET another");
    }

    void onPost(HttpData& data)
    {
        data.getResponse().getJson()["data"] = QSTR("POST another");
    }
};

class Simple : public Action
{
public:
    Simple() : Action()
    {
    }

    const char* getName() const
    {
        return "simple";
    }

    QStringList getTags() const
    {
        static const QStringList list = { "tag1", "tag2" };
        return list;
    }

    std::vector<Input> getInputs() const
    {
        static const std::vector<Input> list =
        {
            Input("someinput"),
            RequiredInput("reqinput"),
            Input("options", "some options", { "selectone", "selectanother" })
        };
        return list;
    }

    void onGet(HttpData& data)
    {
        QFile receivedFile("voice.jpg");
        receivedFile.open(QIODevice::ReadOnly);
        QByteArray arr = receivedFile.readAll();
        receivedFile.close();

        //data.getResponse().getJson()["data"] = QSTR("GET ok");
        //data.getResponse().getJson()["vahag"] = QSTR("vahag avagyan");
        //data.getResponse().finish(arr);
       // data.getResponse().getJson()["vahag"] = QSTR("vahag avagyan");
        QJsonObject object
        {
            {"property1", 1},
            {"property2", 2},
            {"property3", QString(arr.toBase64())}
        };
        data.getResponse().setJson(object);
       // data.getResponse().finish(arr);


    }

    void onPost(HttpData& data)
    {}
        //qDebug() << "onPost";
       
        //QString date = QDate::currentDate().toString("d_M_yyyy") + "_" + QTime::currentTime().toString("h_mm_ss") + "_" + QString::number(qrand());
        //std::system((QString("mkdir /var/www/html/videos/") + date).toStdString().c_str());

        //QString currPath = "/var/www/html/videos/" + date;
        //QString resDir = currPath + "/" + "processedImages";
        //QString inputDir = currPath + "/" + "originalImages";
        //QString detectronPath = "/home/paperspace/Detectron/detectron/";
        //QString resVideoDir = currPath;
        //QString inputVideoPath = currPath + "/originalVideo.mov";

        //std::system((QString("mkdir ") + resDir).toStdString().c_str()); 
        //std::system((QString("mkdir ") + inputDir).toStdString().c_str());

       // QFile receivedFile("receivedFile.jpg");
        //QFile receivedFile(inputVideoPath);
        //receivedFile.open(QIODevice::WriteOnly);
        //receivedFile.write(data.getRequest().getBody());
        //receivedFile.close();

        //cv::VideoCapture cap(inputVideoPath.toStdString());
        //std::vector<cv::Mat> resVector;
        //int size = 0;
        //for (;;) {
        //    cv::Mat frame;
        //    cap >> frame;
        //    if (frame.empty()) {
        //       break;
        //    }
        //    cv::imwrite( inputDir.toStdString() + "/" + QString::number(size).toStdString() + ".jpg", frame);
        //    ++size;
        // }

      //  std::system((QString("rm ") + inputVideoPath).toStdString().c_str());

        //qDebug() << "read all frames" << size;

        //QString run =  "python2 " + detectronPath + "tools/infer_simple.py" +
        //               " --cfg " + detectronPath + "configs/12_2017_baselines/e2e_mask_rcnn_R-101-FPN_2x.yaml" +
        //               " --output-dir " + resDir + " --image-ext jpg" +
        //               " --wts https://s3-us-west-2.amazonaws.com/detectron/35861858/12_2017_baselines/e2e_mask_rcnn_R-101-FPN_2x.yaml.02_32_51.SgT4y1cO/output/train/coco_2014_train:coco_2014_valminusminival/generalized_rcnn/model_final.pkl  " + inputDir;
        
        //QProcess p;
        //p.start(run);
        //p.waitForFinished();

        //QString debugInfo = p.readAllStandardOutput();
        //qDebug() << debugInfo;
        //if (size == 0) {
        //    qDebug() << "video is empty";
        //    cv::VideoWriter writer(resVideoDir.toStdString() + "/res.avi", CV_FOURCC('M','J','P','G') , 30, cv::Size(0, 0), true);
       // }
      //  else
      //  {
       //     qDebug() << "video is not empty";
       //     cv::Mat res = cv::imread(resDir.toStdString() + "/0.jpg.png");
       //     qDebug() << "FPS original!!!!!!! " << cap.get(cv::CAP_PROP_FPS);
       //     std::vector<cv::Mat> resVec;
       /*     for (int j = 0; j <= size; ++j) {
                 cv::Mat res = cv::imread(resDir.toStdString() + "/" + QString::number(j).toStdString() + ".jpg.png");
                 if (!res.empty()) {
                     resVec.push_back(res);
                 }
            }
            int fps = cap.get(cv::CAP_PROP_FPS) * resVec.size() / (size + 1);
            qDebug() << "fps processed" << fps;         
            cv::VideoWriter writer(resVideoDir.toStdString() + "/res.avi", CV_FOURCC('M','J','P','G') , fps/*cap.get(cv::CAP_PROP_FPS), cv::Size(cap.get(cv::CAP_PROP_FRAME_WIDTH), cap.get(cv::CAP_PROP_FRAME_HEIGHT)), true);
            for (int i = 0; i < resVec.size(); ++i) {
                writer << resVec.at(i);
            }
        }
        
        QString ffmpegConverterCommand = "ffmpeg -i " + resVideoDir + "/res.avi -q:v 1 -vcodec mpeg4 -y " + resVideoDir + "/processedVideo.mov";
        qDebug() << "ffmpeg!!!" <<  std::system(ffmpegConverterCommand.toStdString().c_str());
        QString rmAviFileCommand = "rm " + resVideoDir  + "/res.avi";
        qDebug() << std::system(rmAviFileCommand.toStdString().c_str());
        QString rmResultDirCommand = "rm -r " +  resDir;
      //  std::system(rmResultDirCommand.toStdString().c_str());
        QString rmInputDirCommand = "rm -r " + inputDir;
       // std::system(rmInputDirCommand.toStdString().c_str());

 	QFile receivedFile1(resVideoDir + "/processedVideo.mov");
        receivedFile1.open(QIODevice::ReadOnly);
        QByteArray arr = receivedFile1.readAll();
        receivedFile1.close();
        
        QString s =  resVideoDir + "/processedVideo.mov";
        QString jsonPath = currPath + "/json";    
        data.getResponse().getJson()["data"] = QSTR("POST ok");
        QJsonObject object
        {
            {"Tags", "Reserved For Future Use"},
            ///{"OutputInfo", debugInfo},
            //{"Type", "binary"},
            //{"ImgBase64", s}  QString currPath = "/var/www/html/videos/" + date;
         //   {"Processed Video Path", s},
           // {"Processed Images Path", resDir},
          //  {"Original Images Path", inputDir},
          //  {"Original Video Path", inputVideoPath},
            {"FolderPath", date}
        }; 
       QJsonDocument doc(object);
QString strJson(doc.toJson(QJsonDocument::Compact));
        qDebug() << "object" << strJson;
    //    qDebug() << "Processed Images Path" << resDir;
    //    qDebug() << "Original Images Path" << inputDir;
    //    qDebug() << "Original Video Path" << inputVideoPath;
        data.getResponse().setJson(object);
	
    }

    void onPut(HttpData& data)
    {
        data.getResponse().getJson()["data"] = QSTR("PUT ok");
    }

    void onPatch(HttpData& data)
    {
        data.getResponse().getJson()["data"] = QSTR("PATCH ok");
    }*/
};

int main(int argc, char** argv)
{
    auto result = 0;

    QProcess *runServer=new QProcess();
    QString file="/home/ubuntu/bin/RunServer";
    qDebug() << "before";
    runServer->start(file);
    qDebug() << "after";
//    QProcess *Config=new QProcess();
//    QString file1="/root/Desktop/bin/Config";
//    QStringList params;
//    //params << "default";
//    Config->start(file1);
//    Config->waitForFinished();
//     qDebug() << "after Config";

    try
    {
        LOG_TRACE;

        QCoreApplication app(argc, argv);

        HttpServer* svr = HttpServer::getInstance();
        if(!svr->initialize()) {
            std::cerr << "Failed to initialize!" << std::endl;
        }

        auto helloworld = svr->createAction([](HttpData& data) {
                QJsonObject& json = data.getResponse().getJson();
                json["response"] = QSTR("Hello World!");
    });

    helloworld->registerRoute(HttpMethod::GET, "/helloworld");

    auto echobody = svr->createAction([](HttpData& data) {
            QJsonObject& json = data.getResponse().getJson();
            json["response"] = data.getRequest().getJson();
            });

echobody->registerRoute({
                            { HttpMethod::GET, "echobody" },
                            { HttpMethod::GET, "echobody2" },
                            { HttpMethod::POST, "echobody3" }
                        });

auto actionAddImageIntoTrainData = svr->addAction<AddImageIntoTrainData>();
//actionAddImageIntoTrainData->registerRoute(qttp::HttpMethod::POST, "/addImageIntoTrainData/:tag");
actionAddImageIntoTrainData->registerRoute(qttp::HttpMethod::POST, "/addImageIntoTrainData/:tag");


svr->addActionAndRegister<QueryImageFromTrainData>("/queryImageFromTrainData",
{ HttpMethod::GET,
  HttpMethod::POST });


svr->addActionAndRegister<Simple>("/simple",
{ HttpMethod::GET,
  HttpMethod::POST });

svr->addActionAndRegister<Simple>("/simple",
{ "PUT", "PATCH" });

svr->addActionAndRegister<Another>();

svr->startServer();

result = app.exec();
}
catch(std::exception& e)
{
    std::cerr << "ERROR: " << e.what() << std::endl;
}
catch(...)
{
std::cerr << "ERROR: Caught an unknown exception" << std::endl;
}

return result;
}
