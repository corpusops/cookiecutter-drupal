<?php
/* Monitor-status.php
* =====================
* Health Check of the server.
 */

use Drupal\Core\DrupalKernel;
use Symfony\Component\HttpFoundation\Request;

$_GLOBALS['errors'] = array();
function myErrorHandler($errno, $errstr, $errfile, $errline)
{
  if (!(error_reporting() & $errno)) {
      // This error code is not included in error_reporting
      return;
  }
  //$_GLOBALS['errors'][] = "catched PHP error: [$errno] $errstr";
  throw new Exception($errstr,$errno);
  //var_dump($_GLOBALS['errors']); die('hard');
  /* Don't execute PHP internal error handler */
  return true;
}
$old_error_handler = set_error_handler("myErrorHandler");
$t0 = microtime(TRUE);

register_shutdown_function('status_shutdown');
function status_shutdown() {
  exit();
}

try{
  $autoloader = require_once 'autoload.php';
  $kernel = DrupalKernel::createFromRequest(Request::createFromGlobals(), $autoloader, 'prod');
  $kernel->boot();
  $request = $kernel->getContainer()->get('database')->query('SELECT 42');
} catch (Exception $e) {
    // Do nothing, we do not want to die for a little error, do we?
    // $_GLOBALS['errors'][] = "catched PHP error: " . $e->getMessage();
}

// Print all errors.
if (count($_GLOBALS['errors']) > 0) {
  $_GLOBALS['errors'][] = 'Errors on this server will cause it to be removed from the load balancer.';
  header('HTTP/1.1 500 Internal Server Error');
  print implode("<br />\n", $_GLOBALS['errors']);
}
else {
  // Split up this message, to prevent the remote chance of monitoring software
  // reading the source code if mod_php fails and then matching the string.
  print 'CONGRATULATIONS' . ' 200';
}

// Exit immediately, note the shutdown function registered at the top of the file.
exit();

// vim:set et sts=4 ts=4 tw=80:
