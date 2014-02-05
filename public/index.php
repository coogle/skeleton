<?php
/**
 * This makes our life easier when dealing with paths. Everything is relative
 * to the application root now.
 */
chdir(dirname(__DIR__));

if(!defined("APPLICATION_ROOT")) {
    define("APPLICATION_ROOT", dirname(__DIR__));
}

// Decline static file requests back to the PHP built-in webserver
if (php_sapi_name() === 'cli-server' && is_file(__DIR__ . parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH))) {
    return false;
}

if(isset($_SERVER['APPLICATION_ENV']) && !defined('APPLICATION_ENV')) {
    define('APPLICATION_ENV', $_SERVER['APPLICATION_ENV']);
} else if(!defined('APPLICATION_ENV')) {
    define('APPLICATION_ENV', 'development');
}

if (APPLICATION_ENV == 'development') {
	error_reporting(E_ALL);
	ini_set("display_errors", 1);
}

// Setup autoloading
require 'init_autoloader.php';

// Run the application!
Zend\Mvc\Application::init(require 'config/application.config.php')->run();
