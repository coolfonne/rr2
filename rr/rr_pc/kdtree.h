//#include <conio.h>
#include <cstdlib>
#include <iostream>
#include <limits>
#include <time.h>
#include <vector>
#include <algorithm>
#include "segment.h"
using namespace std;

// A few notes...
// Make sure all MikePoints are unique before inserting them into the Kdtree.
// The only functions you should call are the constructor and searchtree:
// Kdtree(const vector<MikePoint> &P)
// vector<MikePoint> searchtree(float x0, float y0, float x1, float y1)

struct MikePoint {
    float x, y;
    Segment seg;   
    
    bool operator==(const MikePoint &p2)
    {
        return (x == p2.x && y == p2.y);
    }
    
    MikePoint(float x, float y, Segment seg)
    {
        this->x = x;
        this->y = y;
        this->seg = seg;
    }
    
    
    MikePoint()
    {
    }
    
};


class Kdtree {
    
    struct Node
    {
        MikePoint p;       
        Node *left, *right;       
        
        Node(const MikePoint &p)
        {
            this->p = p;           
            this->left = NULL;
            this->right = NULL;
        }
        
    };
    
    Node *root;    
    
    bool lessthanx(const MikePoint &p1, const MikePoint &p2)
    {
        if (p1.x != p2.x) return (p1.x < p2.x);
        else return (p1.y < p2.y);
    }
    
    bool lessthany(MikePoint &p1, MikePoint &p2)
    {
        if (p1.y != p2.y) return (p1.y < p2.y);
        else return (p1.x < p2.x);
    }
    
    struct MikePointSortX
    {
        bool operator () (const MikePoint& p1, const MikePoint &p2)
        {
            
            if (p1.x != p2.x) return (p1.x < p2.x);
            else return (p1.y < p2.y);                        
        }
    };
    
    struct MikePointSortY
    {
        bool operator () (const MikePoint& p1, const MikePoint &p2)
        {
            if (p1.y != p2.y) return (p1.y < p2.y);
            else return (p1.x < p2.x);
        }
    };
    
    
    struct Range {
        float x0, y0;
        float x1, y1;       
        
        Range(float x0, float y0, float x1, float y1)
        {
            this->x0 = x0;
            this->y0 = y0;
            this->x1 = x1;
            this->y1 = y1;
        }
        
        Range(void)
        {
        }
        
    };
    
    // depth is 0 for an x level
    // depth is 1 for a y level
    
    Node* buildkdtree(vector<MikePoint> &xsorted, vector<MikePoint> &ysorted, int depth)
    {
        
        if (xsorted.size()==0) return NULL; 
        else if (xsorted.size()==1) return new Node(xsorted[0]);     
        
        int n = xsorted.size();
        int medianindex = (n-1)/2;
        
        if (!depth) {
            MikePoint L = xsorted[medianindex];
            vector<MikePoint> P1newxsorted(xsorted.begin(), xsorted.begin()+medianindex+1);
            vector<MikePoint> P2newxsorted(xsorted.begin()+medianindex+1, xsorted.end());
            vector<MikePoint> P1newysorted, P2newysorted;
            vector<MikePoint>::iterator i = ysorted.begin();
            while (i != ysorted.end())
            {
                MikePoint p = *i;
                if (lessthanx(p, L) || p == L) P1newysorted.push_back(p);
                else P2newysorted.push_back(p);
                ++i;
            }
            
            Node *v = new Node(L);
            v->left = buildkdtree(P1newxsorted, P1newysorted, !depth);
            v->right = buildkdtree(P2newxsorted, P2newysorted, !depth);
            return v;     
        }
        
        else {
            MikePoint L = ysorted[medianindex];
            
            vector<MikePoint> P1newysorted(ysorted.begin(), ysorted.begin()+medianindex+1);
            vector<MikePoint> P2newysorted(ysorted.begin()+medianindex+1, ysorted.end());
            vector<MikePoint> P1newxsorted, P2newxsorted;
            
            vector<MikePoint>::iterator i = xsorted.begin();
            while (i != xsorted.end())
            {
                MikePoint p = *i++;
                if (lessthany(p, L) || p == L) P1newxsorted.push_back(p);
                else P2newxsorted.push_back(p);
            }
            Node *v = new Node(L);
            v->left = buildkdtree(P1newxsorted, P1newysorted, !depth);
            v->right = buildkdtree(P2newxsorted, P2newysorted, !depth);
            return v;     
        }
    }
    
    
    
    Node* buildkdtreemain(const vector<MikePoint> &P)
    {
        if (P.size()==0) return NULL; 
        else if (P.size()==1) return new Node(P[0]);     
        vector<MikePoint> xsorted(P);
        sort(xsorted.begin(), xsorted.end(), MikePointSortX());
        vector<MikePoint> ysorted(P);
        sort(ysorted.begin(), ysorted.end(), MikePointSortY());
        return buildkdtree(xsorted, ysorted, 0);
    }
    
    
    bool MikePointinregion(const MikePoint &p, const Range &r)
    {
        return (
        p.x >= r.x0
        && p.x <= r.x1
        && p.y >= r.y0
        && p.y <= r.y1);
    }
    
    bool isfullycontained(const Range &small, const Range &big)
    {
        return (small.x0 >= big.x0
        && small.y0 >= big.y0
        && small.x1 <= big.x1
        && small.y1 <= big.y1);        
    }
    
    bool intersects(const Range &r0, const Range &r1)
    {
        if (r0.x0 > r1.x1) return false;
        else if (r1.x0 > r0.x1) return false;
        else if (r0.y0 > r1.y1) return false;
        else if (r1.y0 > r0.y1) return false;
        else return true;
    }
    
    void reportsubtree(Node *v, vector<MikePoint> &MikePointoutputvector)
    {
        if (v == NULL) return;
        reportsubtree(v->left, MikePointoutputvector);
        reportsubtree(v->right, MikePointoutputvector);
        
        if (!v->right && !v->left) MikePointoutputvector.push_back(v->p);
    }
    
    
    // depth will be 0 if we're at an x partition and 1 if we're at a y partition
    void searchkdtree(Node *v, const Range &R, int depth, const Range &regionv, vector<MikePoint> &MikePointoutputvector)
    {
        if (v == NULL) return;
        //       cout << "yo" << endl; 
        if (!v->left && !v->right)
        {
            if (MikePointinregion(v->p, R)) MikePointoutputvector.push_back(v->p);
            return;
        }
        
        
        Range leftregion = regionv;
        if (!depth) leftregion.x1 = v->p.x;
        else leftregion.y1 = v->p.y;
        
        if (isfullycontained(leftregion, R)) reportsubtree(v->left, MikePointoutputvector);
        else if (intersects(leftregion, R)) searchkdtree(v->left, R, !depth, leftregion, MikePointoutputvector);
        
        Range rightregion = regionv;
        if (!depth) rightregion.x0 = v->p.x;
        else rightregion.y0 = v->p.y;
        
        if (isfullycontained(rightregion, R)) reportsubtree(v->right, MikePointoutputvector);
        else if (intersects(rightregion, R)) searchkdtree(v->right, R, !depth, rightregion, MikePointoutputvector);
        
    }
    
    
    
    void searchkdtree(Node *v, Range R, vector<MikePoint> &MikePointoutputvector)
    {
        
        if (v == NULL) return;
        
        Range regionv;
        float infinity = std::numeric_limits< float >::infinity();
        
        regionv.x0 = -infinity;
        regionv.y0 = -infinity;
        regionv.x1 = infinity;
        regionv.y1 = infinity;
        
        searchkdtree(v, R, 0, regionv, MikePointoutputvector);
        
    }
    
    
    void deleteallnodes(Node *root)
    {
        if (root == NULL) return;
        deleteallnodes(root->left);
        deleteallnodes(root->right);
        delete root;
    }
    
    public:
    Kdtree(const vector<MikePoint> &P)
    {
        root = buildkdtreemain(P);
    }
    
    vector<MikePoint> searchtree(float x0, float y0, float x1, float y1)
    {
        vector<MikePoint> MikePointoutputvector;
        searchkdtree(root, Range(x0, y0, x1, y1), MikePointoutputvector);
        return MikePointoutputvector;
    }
    
    void searchtree(float x0, float y0, float x1, float y1, vector<MikePoint> &MikePointoutputvector)
    {
        searchkdtree(root, Range(x0, y0, x1, y1), MikePointoutputvector);
    }
    
    
    
    ~Kdtree()
    {
        deleteallnodes(root);
    }
    
};


