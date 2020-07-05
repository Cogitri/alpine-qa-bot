/*
 * SPDX-FileCopyrightText: 2020 Rasmus Thomsen <oss@cogitri.dev>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

namespace TestLib {
    public enum TestMode {
        Comparing,
        Logging,
        Testing,
    }

    public void init_mock_server(Uhm.Server mock_server, TestMode mock_server_test_mode, string test_suite_name) {
        var test_path = Test.build_filename (Test.FileType.DIST, test_suite_name);
        mock_server.trace_directory = File.new_for_path (test_path);
    
        TlsCertificate tls_cert = null;
        try {
            var cert_path = Test.build_filename (Test.FileType.BUILT, "");
            tls_cert = new TlsCertificate.from_files ("%s/cert.pem".printf (cert_path), "%s/key.pem".printf (cert_path));
        } catch (Error e) {
            error ("%s", e.message);
        }
        mock_server.set_tls_certificate (tls_cert);
    
        switch (mock_server_test_mode) {
        case TestMode.Comparing:
            mock_server.enable_logging = false;
            mock_server.enable_online = true;
            break;
        case TestMode.Logging:
            mock_server.enable_logging = true;
            mock_server.enable_online = true;
            break;
        case TestMode.Testing:
            mock_server.enable_logging = false;
            mock_server.enable_online = false;
            break;
        }
    }

    public Soup.Session get_test_soup_session(Uhm.Server mock_server) {
        var soup_logger = new Soup.Logger (Soup.LoggerLogLevel.BODY, -1);
        soup_logger.set_printer ((logger, level, direction, data) => {
            Uhm.Server.received_message_chunk_from_soup (logger, level, direction, data, mock_server);
        });
        var soup_session = new Soup.Session ();
        soup_session.add_feature (soup_logger);
        soup_session.ssl_strict = false;
        return soup_session;
    }
}