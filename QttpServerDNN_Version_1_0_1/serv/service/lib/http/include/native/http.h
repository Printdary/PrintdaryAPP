#ifndef __NATIVE_HTTP_H__
#define __NATIVE_HTTP_H__

#include <stdio.h>
#include <sys/types.h>
#include <sstream>
#include <iostream>
#include <http_parser.h>
#include "base.h"
#include "handle.h"
#include "net.h"
#include "tcp.h"
#include "text.h"
#include "callback.h"

namespace native
{
namespace http
{
class url_parse_exception : public native::exception
{
  public:
    url_parse_exception(const std::string& message = "Failed to parse URL.");
};

class response_exception : public native::exception
{
  public:
    response_exception(const std::string& message = "HTTP respsonse error.");
};

class url_obj
{
  friend class client_context;

  public:
    url_obj();
    ~url_obj();

    url_obj(const url_obj& c);
    url_obj& operator =(const url_obj& c);

  public:
    std::string schema() const;
    std::string host() const;
    int port() const;
    std::string path() const;
    std::string query() const;
    std::string fragment() const;

  private:
    void from_buf(const char* buf, std::size_t len, bool is_connect = false);

    bool has_schema() const {
      return (handle_.field_set & (1 << UF_SCHEMA)) != 0;
    }
    bool has_host() const {
      return (handle_.field_set & (1 << UF_HOST)) != 0;
    }
    bool has_port() const {
      return (handle_.field_set & (1 << UF_PORT)) != 0;
    }
    bool has_path() const {
      return (handle_.field_set & (1 << UF_PATH)) != 0;
    }
    bool has_query() const {
      return (handle_.field_set & (1 << UF_QUERY)) != 0;
    }
    bool has_fragment() const {
      return (handle_.field_set & (1 << UF_FRAGMENT)) != 0;
    }

  private:
    http_parser_url handle_;
    std::string buf_;
};

class client_context;
typedef std::shared_ptr<client_context> http_client_ptr;

class response
{
  friend class client_context;

  private:
    response(client_context* client, native::net::tcp* socket);
    ~response();

  public:

    bool end(const std::string& body) {
      return end(body.length(), body.c_str());
    }

    bool end(size_t length, const char* body)
    {
      write(length, body);
      return close();
    }

    void write(const std::string& body)
    {
      return write(body.length(), body.c_str());
    }

    void write(size_t length, const char* body);

    bool close();

    void set_status(int status_code) {
      status_ = status_code;
    }

    int get_status() const {
      return status_;
    }

    void set_header(const std::string& key, const std::string& value) {
      headers_[key] = value;
    }

    const std::map<std::string, std::string, native::text::ci_less>& get_headers() const {
      return headers_;
    }

    bool getsockname(bool& ip4, std::string& ip, int& port) const
    {
      return socket_->getsockname(ip4, ip, port);
    }

    bool getpeername(bool& ip4, std::string& ip, int& port) const
    {
      return socket_->getpeername(ip4, ip, port);
    }

    static std::string get_status_text(int status);

  private:
    http_client_ptr client_;
    native::net::tcp* socket_;
    std::map<std::string, std::string, native::text::ci_less> headers_;
    int status_;
    std::stringstream response_text_;
    bool is_response_written_;
};

class request
{
  friend class client_context;

  private:
    request();
    ~request();

  public:
    const url_obj& url() const {
      return url_;
    }

    const std::string& get_header(const std::string& key) const;
    bool get_header(const std::string& key, std::string& value) const;
    const std::map<std::string, std::string, native::text::ci_less>& get_headers() const;

    std::string get_body (void) const {
      return body_.str();
    }

    std::stringstream& get_raw_body (void) {
      return body_;
    }
    const std::string& get_method (void) const {
      return method_;
    }

    uint64_t get_timestamp(void) const {
      return timestamp_;
    }

  private:
    url_obj url_;
    std::map<std::string, std::string, native::text::ci_less> headers_;
    std::stringstream body_;
    std::string default_value_;
    std::string method_;
    uint64_t timestamp_;
};

class client_context
{
  friend class http;

  private:
    client_context(native::net::tcp* server);

  public:
    ~client_context();

  private:
    bool parse(std::function<void(request&, response&)> callback);

  private:
    http_parser parser_;
    http_parser_settings parser_settings_;
    bool was_header_value_;
    std::string last_header_field_;
    std::string last_header_value_;

    std::shared_ptr<native::net::tcp> socket_;
    request* request_;
    response* response_;

    callbacks* callback_lut_;
};

class http
{
  public:
    http();
    virtual ~http();

  public:
    bool listen(const std::string& ip, int port, std::function<void(request&, response&)> callback);

  private:
    std::shared_ptr<native::net::tcp> socket_;
};

typedef http_method method;
typedef http_parser_url_fields url_fields;
typedef http_errno error;

const char* get_error_name(error err);
const char* get_error_description(error err);
const char* get_method_name(method m);
}
}

#endif
