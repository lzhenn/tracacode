#include<iostream>
#include<time.h>
 
using namespace std;
 
int main()
{
    double d=3.1416;
    char ch = * (char *) &d;
    cout<<&d<<endl;
    cout<<ch<<endl;
}
