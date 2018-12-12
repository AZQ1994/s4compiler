// classes example
//#include <iostream>
//using namespace std;

class Rectangle {
    int width, height;
  public:
    void set_values (int,int);
    int area() {
      if (width > 0)
        return width*height;
      else return width-height;
    }
};

void Rectangle::set_values (int x, int y) {
  width = x;
  height = y;
}
int res;
int input1=3, input2=4;
int main () {
  Rectangle rect;
  rect.set_values (input1,input2);
  //cout << "area: " << rect.area();
  res = rect.area();
  return res;
}
