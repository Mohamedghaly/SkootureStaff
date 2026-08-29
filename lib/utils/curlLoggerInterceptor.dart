import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'dart:convert';

/// Returns the value safely quoted for shell usage.
/// If the value contains a single quote, uses double quotes and escapes inner double quotes.
String shellQuote(String value) {
  if (value.contains("'")) {
    // Replace any double quotes with escaped double quotes.
    String escaped = value.replaceAll('"', r'\"');
    return '"$escaped"';
  } else {
    return "'$value'";
  }
}

class CurlLoggerInterceptor extends Interceptor {
  final bool printOnSuccess;
  final bool printOnError;
  final bool convertFormData;

  CurlLoggerInterceptor({
    this.printOnSuccess = true,
    this.printOnError = true,
    this.convertFormData = false,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final method = options.method.toUpperCase();
      final url = options.uri.toString();
      var curlCommand = "curl -X $method ${shellQuote(url)}";

      // Append headers to the cURL command.
      options.headers.forEach((key, value) {
        if (value != null) {
          curlCommand += " -H ${shellQuote('$key: $value')}";
        }
      });

      // Handle request data based on content type.
      if (options.data != null) {
        final contentType = options.contentType?.toString() ??
            options.headers['content-type']?.toString() ??
            '';

        if (options.data is FormData) {
          // Handle FormData (multipart/form-data).
          final formData = options.data as FormData;

          // Append form fields.
          for (final field in formData.fields) {
            curlCommand += " -F ${shellQuote('${field.key}=${field.value}')}";
          }

          // Append files.
          for (final file in formData.files) {
            final filename = file.value.filename ?? 'file';
            curlCommand += " -F ${shellQuote('${file.key}=@$filename')}";
          }

          // If convertFormData is true, also show the fields as JSON for debugging
          if (convertFormData) {
            final fieldsMap = <String, dynamic>{};
            for (final field in formData.fields) {
              fieldsMap[field.key] = field.value;
            }

            final filesList = <Map<String, dynamic>>[];
            for (final file in formData.files) {
              filesList.add({
                'field': file.key,
                'filename': file.value.filename ?? 'file',
                'contentType': file.value.contentType?.mimeType ?? 'unknown',
              });
            }
          }
        } else if (contentType.contains('application/x-www-form-urlencoded')) {
          // Handle URL-encoded data.
          if (options.data is Map) {
            (options.data as Map).forEach((key, value) {
              curlCommand += " -d ${shellQuote('$key=$value')}";
            });
          } else if (options.data is String) {
            curlCommand += " -d ${shellQuote(options.data)}";
          }
        } else if (contentType.contains('application/json') ||
            options.data is Map ||
            options.data is List) {
          // Handle JSON data with --data flag for proper JSON body.
          String jsonData;
          if (options.data is String) {
            jsonData = options.data;
          } else {
            try {
              jsonData = jsonEncode(options.data);
            } catch (e) {
              jsonData = options.data.toString();
            }
          }
          curlCommand += " --data ${shellQuote(jsonData)}";
        } else {
          // Handle raw string data.
          curlCommand += " --data ${shellQuote(options.data.toString())}";
        }
      }

      developer.log('\n🔍 cURL Request:\n$curlCommand\n', name: 'CURL_LOG');
    } catch (e) {
      developer.log(
        '\n⚠️ Error generating cURL: $e\n',
        name: 'CURL_LOG',
      );
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (printOnSuccess) {}
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (printOnError) {
      developer.log(
        '\n❌ Error [${err.response?.statusCode}]: ${err.requestOptions.uri}\n'
        'Message: ${err.message}\n',
        name: 'CURL_LOG',
      );
    }
    super.onError(err, handler);
  }
}
