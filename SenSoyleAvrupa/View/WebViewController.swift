//
//  WebViewController.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 12.03.22.
//

import WebKit

class WebViewController: UIViewController {

    // MARK: Properties
    private let url: URL

    // MARK: Views
    var webView: WKWebView!

    init(url: URL) {
        self.url = url

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
}

extension WebViewController: WKNavigationDelegate { }
