<?php
	$source = file_get_contents("dbIP.txt");
	$link = mysqli_connect($source, "root", "root", "db_name");
	/* check connection */
	if (mysqli_connect_errno()) {
		printf("Connect failed: %s\n", mysqli_connect_error());
		exit();
	}
