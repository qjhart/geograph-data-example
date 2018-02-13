	CREATE OR REPLACE FUNCTION circle_intersection(
	 center geometry(point),
	 r float,
	 line geometry(linestring),
	 add_radius float default 0,
	 OUT intersection geometry(point) )
	AS $$
	DECLARE
		theta float;
	  s geometry(point);
    e geometry(point);
		x float;
		y float;
		b float;
		c float;
		l1 float;
	BEGIN
    s := st_startPoint(line);
    e := st_endPoint(line);
		theta := atan2(st_y(e)-st_y(s),st_x(e)-st_x(s)) ;
		x := st_x(s)-st_x(center);
		y := st_y(s)-st_y(center);
		-- a=1
		b=2*(y*sin(theta)+x*cos(theta));
		c=(x^2+y^2)-r^2;
		-- quadratic formula
		l1 := ( -b + sqrt(b^2 - 4*c) ) / 2a;
--		l2 := ( -b - sqrt(b^2 - 4*c) ) / 2a;
    intersection:=st_translate(s,l1*cos(theta),l1*sin(theta));
	RETURN;
	END;
	$$
	LANGUAGE 'plpgsql' IMMUTABLE;

	CREATE OR REPLACE FUNCTION circle_distance_fraction(
	 center geometry(point),
	 r float,
	 line geometry(linestring),
	 add_radius float default 0,
	 OUT fraction float,
	 OUT reverse boolean)
	AS $$
	DECLARE
		theta float;
	  s geometry(point);
    e geometry(point);
		x float;
		y float;
		b float;
		c float;
		l1 float;
	BEGIN
	  reverse := false;
    s := st_startPoint(line);
    e := st_endPoint(line);
		if (st_distance(s,center) < r) then
			 if (st_distance(e,center) < r) then
			 		fraction :=1;  -- Line is all in circle
					RETURN;
			 end if;
		else
			if (st_distance(e,center) > r) then
			 		fraction := 0;
					RETURN;
			 end if;
			 reverse := true;
			 s := st_endPoint(line);
			 e := st_startPoint(line);
		end if;
		theta := atan2(st_y(e)-st_y(s),st_x(e)-st_x(s)) ;
		x := st_x(s)-st_x(center);
		y := st_y(s)-st_y(center);
		-- a=1
		b=2*(y*sin(theta)+x*cos(theta));
		c=(x^2+y^2)-r^2;
		-- quadratic formula
		l1 := ( -b + sqrt(b^2 - 4*c) ) / 2a;
		fraction=l1/st_length(line);
	RETURN;
	END;
	$$
	LANGUAGE 'plpgsql' IMMUTABLE;
