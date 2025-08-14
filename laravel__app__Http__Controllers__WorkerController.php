<?php
namespace App\Http\Controllers;
use App\Models\Worker;

class WorkerController extends Controller {
  public function index(){ return Worker::paginate(10); }
  public function show(Worker $worker){ return $worker; }
}
