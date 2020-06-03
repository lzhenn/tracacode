#include<iostream>
#include<time.h>
 
using namespace std;
 
int main()
{
    for (int i = 0; i < 100000000; i++)
    {
        i++;
    }
    cout << "Totle Time : " << (double)clock() /CLOCKS_PER_SEC<< "s" << endl;
    return 0;
}
