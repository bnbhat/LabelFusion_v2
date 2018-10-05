=====
LabelFusion
=====

This readme is to document how to create your own data with LabelFusion.

If you're looking to download the example LabelFusion dataset, go here: http://labelfusion.csail.mit.edu/#data

=====
Setup
=====

Recommended setup is through our Docker_.

.. _Docker: https://hub.docker.com/r/robotlocomotion/labelfusion/

If instead you'd prefer a native install, go to:  "Setup Instructions".

.. _Setup_Instructions: https://github.com/RobotLocomotion/LabelFusion/blob/master/docs/setup.rst

===========================
Quick Pipeline Instructions
===========================

This is the quick version.  If you'd prefer to go step-by-step manually, see Pipeline_Instructions_.

.. _Pipeline_Instructions: https://github.com/RobotLocomotion/LabelFusion/blob/master/docs/pipeline.rst

Collect raw data from Xtion
---------------------------

First, :code:`cdlf && cd data/logs`, then make a new directory for your data.  In one terminal, run:

::

	openni2-camera-lcm

In another, run:

::

	lcm-logger

Your data will be saved in current directory as :code:`lcmlog-*`.


Collect raw data from Realsense
---------------------------

First, install `librealsense  <https://github.com/IntelRealSense/librealsense>`_
, `intel_ros_relasense <https://github.com/intel-ros/realsense>`_
and `rgbd_ros_to_lcm <https://github.com/MobileManipulation/rgbd_ros_to_lcm>`_

Second, :code:`cdlf && cd data/logs`, then make a new directory for your data.  In one terminal, run:

::

	roscore

In one, run:

::

	roslaunch realsense2_camera rs_rgbd.launch

modify rgbd_ros_to_lcm topic:
modify this file ~/catkin_ws/src/rgbd_ros_to_lcm/launch/lcm_republisher.launch to

.. code-block:: 

	<?xml version="1.0"?>
	<launch>
	  <node name="lcm_republisher" pkg="rgbd_ros_to_lcm" type="lcm_republisher" output="screen" respawn="false" >
	    <rosparam subst_value="true">      
	      # input parameters
	      subscribe_point_cloud: false
	      rgb_topic: /camera/color/image_raw
	      depth_topic: /camera/aligned_depth_to_color/image_raw
	      cloud_topic: /camera/depth_registered/points

	      # output parameters
	      output_lcm_channel: "OPENNI_FRAME"
	      compress_rgb: true
	      compress_depth: true

	      debug_print_statements: true
	    </rosparam>
	  </node>
	</launch>

and run

::

    roslaunch rgbd_ros_to_lcm lcm_republisher.launch

In another, run:

::

	lcm-logger

Your data will be saved in current directory as :code:`lcmlog-*`.

Process into labeled training data
----------------------------------

First we will launch a log player with a slider, and a viewer.  The terminal will prompt for a start and end time to trim the log, then save the outputs:

::

	run_trim

Next, we prepare for object pose fitting, by running ElasticFusion and formatting the output:

::

	run_prep

Next, launch the object alignment tool and follow the three steps:

::

	run_alignment_tool

1. 	Check available object types:

    - In your data directory, open ``object_data.yaml`` and review the available objects, and add the objects / meshes that you need.

      - If you need multiple instances of the same object, you will need to create separate copies of the object with unique names (e.g. ``drill-1``, ``drill-2``, ...). For networks that do object detection, ensure that you remove this distinction from your labels / classes.

2. 	Align the reconstructed point cloud:

	- Open measurement panel (View -> Measurement Panel), then check Enabled in measurement panel
	- Use ``shift + click`` and click two points: first on the surface of the table, then on a point above the table
	- Open Director terminal with F8 and run::

		gr.rotateReconstructionToStandardOrientation()

	- Close the ``run_alignment_tool`` application (ctrl + c) and rerun.

3. 	Segment the pointcloud above the table

	- Same as above, use ``shift + click`` and click two points: first on the
	surface of the table, then on a point above the table
	- Open Director terminal with F8 and run::

		gr.segmentTable()
		gr.saveAboveTablePolyData()

	- Close the ``run_alignment_tool`` application (ctrl + c) and rerun.

4. 	Align each object and crop point clouds.

	- Assign the current object you're aligning, e.g.::
	
		objectName = "drill"

	- Launch point cloud alignment::

	    gr.launchObjectAlignment(objectName)

	  This launches a new window. Click the same three points in model and on pointcloud. Using ``shift + click`` to do this. After you do this the affordance should appear in main window using the transform that was just computed.

	  -	If the results are inaccurate, you can rerun the above command, or you  can double-click on each affordance and move it with an interactive marker: ``left-click`` to translate along an axis, ``right-click`` to rotate along an axis.

	- When you are done with an object's registration (or just wish to save intermediate poses), run::

		gr.saveRegistrationResults()

After the alignment outputs have been saved, we can create the labeled data:

::

	run_create_data
	
By default, only RGB images and labels will be saved.  If you'd also like to save depth images, use the :code:`-d` flag:

::

	run_create_data -d



Train SegNet on labeled data
----------------------------

Navigate to :code:`/SegNet/MovingCamera/`

Copy all the data you want to use (created by :code:`run_create_data` from different datasets) into :code:`./train`

Use a different subdirectory inside :code:`/train/` for each log, i.e.:

::

        /train/log-1
        /train/log-2

Then resize all of the training images to a better size for training::

	python resize_all_images.py

Finally, create the description of image-label pairs needed as SegNet input::

	python create_traiing_set_list.py

To train SegNet::

	cd /
	./SegNet/caffe-segnet/build/tools/caffe train -gpu 0 -solver /SegNet/Models/moving_camera_solver.prototxt

