class Line {
  PVector origin;
  PVector t_comp;
  
  Line(PVector p1, PVector p2) {
    origin = p2;
    t_comp = p1.sub(p2);
  }
  
  float distance(Line line2) {
    PVector pq = PVector.sub(this.origin, line2.origin);
    PVector cros = this.t_comp.cross(line2.t_comp);
    return abs(PVector.dot(pq, cros))/cros.mag();
  }
  
  float distPt(PVector pt) {
    PVector pq = PVector.sub(this.origin, pt);
    PVector u = this.t_comp;
    return (pq.cross(u)).mag()/u.mag();
  }
  
  PVector intersect(Line line2) {
    PVector p1 = this.origin;
    PVector d1 = this.t_comp;
    PVector p2 = line2.origin;
    PVector d2 = line2.t_comp;
    PVector n = d1.cross(d2);
    PVector n1 = d1.cross(n);
    PVector n2 = d2.cross(n);
    PVector c1 = PVector.add(p1, PVector.mult(d1,PVector.dot(PVector.sub(p2,p1), n2)/PVector.dot(d1,n2)));
    PVector c2 = PVector.add(p2, PVector.mult(d2,PVector.dot(PVector.sub(p1,p2), n1)/PVector.dot(d2,n1)));
    return PVector.mult(PVector.add(c1,c2),0.5);
  }
  
  void show() {
    PVector pt = PVector.add(this.t_comp, this.origin);
    point(pt.x, pt.y, pt.z);
  }
  
}
