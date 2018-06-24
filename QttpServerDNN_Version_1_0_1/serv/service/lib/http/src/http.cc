#include "native/http.h"

using namespace native;

http::url_parse_exception::url_parse_exception(const std::string& message) :
  native::exception(message)
{
}

http::response_exception::response_exception(const std::string& message) :
  native::exception(message)
{
}

http::url_obj::url_obj() :
  handle_(),
  buf_()
{
}

http::url_obj::url_obj(const url_obj& c) :
  handle_(c.handle_),
  buf_(c.buf_)
{
}

http::url_obj& http::url_obj::operator =(const url_obj& c)
{
  handle_ = c.handle_;
  buf_ = c.buf_;
  return *this;
}

http::url_obj::~url_obj()
{
}

std::string http::url_obj::schema() const
{
  if(has_schema()) return buf_.substr(handle_.field_data[UF_SCHEMA].off, handle_.field_data[UF_SCHEMA].len);
  return "HTTP";
}

std::string http::url_obj::host() const
{
  // TODO: if not specified, use host name
  if(has_schema()) return buf_.substr(handle_.field_data[UF_HOST].off, handle_.field_data[UF_HOST].len);
  return std::string("localhost");
}

int http::url_obj::port() const
{
  if(has_path()) return static_cast<int>(handle_.port);
  return (schema() == "HTTP" ? 80 : 443);
}

std::string http::url_obj::path() const
{
  if(has_path()) return buf_.substr(handle_.field_data[UF_PATH].off, handle_.field_data[UF_PATH].len);
  return std::string("/");
}

std::string http::url_obj::query() const
{
  if(has_query()) return buf_.substr(handle_.field_data[UF_QUERY].off, handle_.field_data[UF_QUERY].len);
  return std::string();
}

std::string http::url_obj::fragment() const
{
  if(has_query()) return buf_.substr(handle_.field_data[UF_FRAGMENT].off, handle_.field_data[UF_FRAGMENT].len);
  return std::string();
}

void http::url_obj::from_buf(const char* buf, std::size_t len, bool is_connect)
{
  // TODO: validate input parameters

  buf_ = std::string(buf, len);
  if(http_parser_parse_url(buf, len, is_connect, &handle_) != 0)
  {
    // failed for some reason
    // TODO: let the caller know the error code (or error message)
    throw url_parse_exception();
  }
}

http::response::response(client_context* client, native::net::tcp* socket) :
  client_(client),
  socket_(socket),
  headers_(),
  status_(200),
  response_text_(),
  is_response_written_(false)
{
  headers_["Content-Type"] = "text/html";
}

http::response::~response()
{
}

void http::response::write(size_t length, const char* body)
{
  if(!is_response_written_)
  {
    is_response_written_ = true;
    if(headers_.find("Content-Length") == headers_.end())
    {
      std::stringstream ss;
      ss << (length > 0 && body != nullptr ? length : 0);
      headers_["Content-Length"] = ss.str();
    }

    response_text_ << "HTTP/1.1 ";
    response_text_ << status_ << " " << get_status_text(status_) << "\r\n";
    for(auto h : headers_)
    {
      response_text_ << h.first << ": " << h.second << "\r\n";
    }
    response_text_ << "\r\n";
    if(length > 0 && body != nullptr)
    {
      response_text_.write(body, length);
    }
  }
  else
  {
    if(length > 0 && body != nullptr)
    {
      response_text_.write(body, length);
    }
  }

}

bool http::response::close()
{
  auto str = response_text_.str();
  return socket_->write(str.c_str(), static_cast<int>(str.length()), [ = ](native::error e) {
    if(e)
    {
      PRINT_STDERR("ERROR while trying to close response");
      PRINT_NN_ERROR(e);
    }
    // clean up
    client_.reset();
  });
}

std::string http::response::get_status_text(int status)
{
  switch(status)
  {
    case 100: return "Continue";
    case 101: return "Switching Protocols";
    case 102: return "Processing"; // RFC 2518, obsoleted by RFC 4918
    case 200: return "OK";
    case 201: return "Created";
    case 202: return "Accepted";
    case 203: return "Non-Authoritative Information";
    case 204: return "No Content";
    case 205: return "Reset Content";
    case 206: return "Partial Content";
    case 207: return "Multi-Status";
    case 300: return "Multiple Choices";
    case 301: return "Moved Permanently";
    case 302: return "Found";
    case 303: return "See Other";
    case 304: return "Not Modified";
    case 305: return "Use Proxy";
    //case 306: return "(reserved)";
    case 307: return "Temporary Redirect";
    case 308: return "Permanent Redirect";         // RFC 7238
    case 400: return "Bad Request";
    case 401: return "Unauthorized";
    case 402: return "Payment Required";
    case 403: return "Forbidden";
    case 404: return "Not Found";
    case 405: return "Method Not Allowed";
    case 406: return "Not Acceptable";
    case 407: return "Proxy Authentication Required";
    case 408: return "Request Timeout";
    case 409: return "Conflict";
    case 410: return "Gone";
    case 411: return "Length Required";
    case 412: return "Precondition Failed";
    case 413: return "Request Entity Too Large";
    case 414: return "Request-URI Too Long";
    case 415: return "Unsupported Media Type";
    case 416: return "Requested Range Not Satisfiable";
    case 417: return "Expectation Faiiled";
    case 418: return "I'm a teapot"; //RFC2324.
    case 422: return "Unprocessable Entity";       // RFC 4918
    case 423: return "Locked";                     // RFC 4918
    case 424: return "Failed Dependency";          // RFC 4918
    case 425: return "Unordered Collection";       // RFC 4918
    case 426: return "Upgrade Required";           // RFC 2817
    case 428: return "Precondition Required";      // RFC 6585
    case 429: return "Too Many Requests";          // RFC 6585
    case 431: return "Request Header Fields Too Large";// RFC 6585
    case 500: return "Internal Server Error";
    case 501: return "Not Implemented";
    case 502: return "Bad Gateway";
    case 503: return "Service Unavailable";
    case 504: return "Gateway Time-out";
    case 505: return "HTTP Version Not Supported";
    case 506: return "Variant Also Negotiates";         // RFC2295
    case 507: return "Insufficient Storage";            // RFC4918
    case 509: return "Bandwidth Limit Exceeded";
    case 510: return "Not Extended";                    // RFC2774
    case 511: return "Network Authentication Required"; // RFC 6585
    default:
      std::stringstream err_str("Unsupported status code:");
      err_str << status;
      throw response_exception(err_str.str());
  }
}

http::request::request() :
  url_(),
  headers_(),
  body_(),
  default_value_(),
  method_(),
  timestamp_(uv_hrtime())
{
}

http::request::~request()
{
}

const std::string& http::request::get_header(const std::string& key) const
{
  auto it = headers_.find(key);
  if(it != headers_.end()) return it->second;
  return default_value_;
}

bool http::request::get_header(const std::string& key, std::string& value) const
{
  auto it = headers_.find(key);
  if(it != headers_.end())
  {
    value = it->second;
    return true;
  }
  return false;
}

const std::map<std::string, std::string, native::text::ci_less>& http::request::get_headers() const
{
  return headers_;
}

http::client_context::client_context(native::net::tcp* server) :
  parser_(),
  parser_settings_(),
  was_header_value_(true),
  last_header_field_(),
  last_header_value_(),
  socket_(nullptr),
  request_(nullptr),
  response_(nullptr),
  callback_lut_(new callbacks(1))
{
  assert(server);

  // TODO: Check Error.
  //
  // TODO: Should this also toggle between SSL?

  socket_ = std::shared_ptr<native::net::tcp> (new native::net::tcp);
  server->accept(socket_.get());
}

http::client_context::~client_context()
{
  if(request_)
  {
    delete request_;
    request_ = nullptr;
  }

  if(response_)
  {
    delete response_;
    response_ = nullptr;
  }

  if(callback_lut_)
  {
    delete callback_lut_;
    callback_lut_ = nullptr;
  }

  if(socket_.use_count())
  {
    socket_->close([ = ](){
      PRINT_DBG("Socket closed");
    });
  }
}

bool http::client_context::parse(std::function<void(request&, response&)> callback)
{
  request_ = new request;
  response_ = new response(this, socket_.get());

  http_parser_init(&parser_, HTTP_REQUEST);
  parser_.data = this;

  // store callback object
  callbacks::store(callback_lut_, 0, callback);

  parser_settings_.on_url = [](http_parser* parser, const char *at, size_t len) {
                              auto client = reinterpret_cast<client_context*>(parser->data);
                              try
                              {
                                client->request_->url_.from_buf(at, len);
                              }
                              catch(const url_parse_exception& ex)
                              {
                                // from_buf() can throw an exception.
                                PRINT_STDERR(ex.message());

                                // TODO: HOW DO WE HANDLE THIS?
                              }
                              return 0;
                            };

  parser_settings_.on_header_field = [](http_parser* parser, const char* at, size_t len) {
                                       auto client = reinterpret_cast<client_context*>(parser->data);
                                       if(client->was_header_value_)
                                       {
                                         // new field started
                                         if(!client->last_header_field_.empty())
                                         {
                                           // add new entry
                                           client->request_->headers_[client->last_header_field_] = client->last_header_value_;
                                           client->last_header_value_.clear();
                                         }

                                         client->last_header_field_ = std::string(at, len);
                                         client->was_header_value_ = false;
                                       }
                                       else
                                       {
                                         // appending
                                         client->last_header_field_ += std::string(at, len);
                                       }
                                       return 0;
                                     };

  parser_settings_.on_header_value = [](http_parser* parser, const char* at, size_t len) {
                                       auto client = reinterpret_cast<client_context*>(parser->data);

                                       if(!client->was_header_value_)
                                       {
                                         client->last_header_value_ = std::string(at, len);
                                         client->was_header_value_ = true;
                                       }
                                       else
                                       {
                                         // appending
                                         client->last_header_value_ += std::string(at, len);
                                       }
                                       return 0;
                                     };

  parser_settings_.on_headers_complete = [](http_parser* parser) {
                                           auto client = reinterpret_cast<client_context*>(parser->data);
                                           // add last entry if any
                                           if(!client->last_header_field_.empty()) {
                                             // add new entry
                                             client->request_->headers_[client->last_header_field_] = client->last_header_value_;
                                           }
                                           return 0; // 1 to prevent reading of message body.
                                         };

  parser_settings_.on_body = [](http_parser* parser, const char* at, size_t len) {
                               PRINT_DBG("on_body: len of 'char* at' is " << len);
                               auto client = reinterpret_cast<client_context*>(parser->data);
                               client->request_->body_.write(at, len);
                               return 0;
                             };

  parser_settings_.on_message_complete = [](http_parser* parser) {
                                           PRINT_DBG("on_message_complete, so invoke the callback");
                                           auto client = reinterpret_cast<client_context*>(parser->data);
                                           client->request_->method_ = http_method_str((http_method)parser->method);
                                           // invoke stored callback object
                                           callbacks::invoke<decltype(callback)>(client->callback_lut_, 0, *client->request_, *client->response_);
                                           return 1; // 0 or 1?
                                         };

  socket_->read_start([ = ](const char* buf, int len) {
    if ((buf == nullptr) || (len < 0)) {
      response_->set_status(500);
    } else {
      http_parser_execute(&parser_, &parser_settings_, buf, len);
    }
  });

  return true;
}

http::http::http() : socket_(new native::net::tcp)
{
}

http::http::~http()
{
  if(socket_)
  {
    socket_->close([](){
      PRINT_DBG("Closing socket");
    });
  }
}

bool http::http::listen(const std::string& ip, int port, std::function<void(request&, response&)> callback)
{
  if(!socket_->bind(ip, port)) {
    PRINT_STDERR("Failed to bind to ip/port " << ip << ":" << port);
    return false;
  }
  auto closed = [](){
                  PRINT_STDERR("Closing socket due to an error");
                };

  auto connected = [ = ](native::error err) {
                     if(err)
                     {
                       // TODO: handle client connection error
                       PRINT_NN_ERROR(err);
                       socket_.get()->close(closed);
                     }
                     else
                     {
                       auto client = new client_context(socket_.get());
                       client->parse(callback);
                     }
                   };

  return socket_->listen(connected);
}

const char* http::get_error_name(error err)
{
  return http_errno_name(err);
}

const char* http::get_error_description(error err)
{
  return http_errno_description(err);
}

const char* http::get_method_name(method m)
{
  return http_method_str(m);
}
