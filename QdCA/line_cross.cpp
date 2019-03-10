#include <iostream> 
#include <vector> 
#include <string> 
#include <map> 

using namespace std; 
vector<string> split(const string& s, const char& c)
{
	string buff{""};
	vector<string> v;
	
	for(auto n:s)
	{
		if(n != c) buff+=n; else
		if(n == c && buff != "") { v.push_back(buff); buff = ""; }
	}
	if(buff != "") v.push_back(buff);
	
	return v;
}

void kill(vector<bool>& current, int idx)
{
	current.erase(current.begin()+idx); 
}

void inverse(vector<bool>& current, int idx)
{
	current[idx] = !current[idx];	
}

void split(vector<bool>& current, int idx)
{
	current.insert(current.begin() + idx, current[idx]);
}

void merge_or(vector<bool>& res, int idx)
{
	res[idx] = res[idx] || res[idx + 1];
	res.erase(res.begin()+idx + 1); 
}

void merge_and(vector<bool>& res, int idx)
{	
	res[idx] = res[idx] && res[idx + 1];
	res.erase(res.begin()+idx + 1);
}

void majority(vector<bool>& res, int idx)
{
	res[idx] = (res[idx] && res[idx + 1]) || (res[idx] && res[idx + 2]) || (res[idx + 2] && res[idx + 1]);
	
	res.erase(res.begin()+idx + 1);
	res.erase(res.begin()+idx + 1);
}

void print_vec(const vector<bool>& current)
{
	for(int i = 0; i < current.size(); i++)
		cout << current[i] << ",";
	
	cout << "\n";
}

class single_logic_path
{
public: 
	vector<vector<bool> > vec;
	string evolution_path; 
	int gates = 0; 

	single_logic_path()
	{
		vec.push_back(vector<bool>{true, true, true});
		vec.push_back(vector<bool>{true, true, false});
		vec.push_back(vector<bool>{true, false, true});
		vec.push_back(vector<bool>{true, false, false});
		
		vec.push_back(vector<bool>{false, true, true});
		vec.push_back(vector<bool>{false, true, false});
		vec.push_back(vector<bool>{false, false, true});
		vec.push_back(vector<bool>{false, false, false});
	}
	
	single_logic_path(const single_logic_path& other)
	{
		for(int i = 0; i < other.vec.size(); i++)
			vec.push_back(other.vec[i]);
		
		evolution_path = string(other.evolution_path);
		gates = other.gates; 
	}
	
	void apply_function(vector<vector<bool> >& in, int idx, void (*op)(vector<bool>&, int))
	{
		for(int i = 0; i < in.size(); i++)
			op(in[i], idx);
	}
	
	vector<single_logic_path> evolve()
	{
		const int max_width = 4;
		
		vector<single_logic_path> result; 
		
		for(int i = 0; i < vec[0].size(); i++)
		{
			single_logic_path slp(*this);
			apply_function(slp.vec, i, &inverse);
			slp.evolution_path += " invese " + to_string(i);
			result.push_back(slp);
		}
		
		
		for(int i = 0; i < vec[0].size(); i++)
		{
			single_logic_path slp(*this);
			apply_function(slp.vec, i, &split);
			slp.evolution_path += " split " + to_string(i);
			if(slp.vec[0].size() >= 3 && slp.vec[0].size() <= max_width)
				result.push_back(slp);
		}
		
		for(int i = 0; i < vec[0].size() - 1; i++)
		{
			single_logic_path slp(*this);
			apply_function(slp.vec, i, &merge_or);
			slp.gates++; 
			slp.evolution_path += " merge_or " + to_string(i);
			if(slp.vec[0].size() >= 3 && slp.vec[0].size() <= max_width)
				result.push_back(slp);
		}
		
		for(int i = 0; i < vec[0].size() - 1; i++)
		{
			single_logic_path slp(*this);
			apply_function(slp.vec, i, &merge_and);
			slp.evolution_path += " merge_and " + to_string(i);
			slp.gates++; 
			if(slp.vec[0].size() >= 3 && slp.vec[0].size() <= max_width)
				result.push_back(slp);
		}
		
		for(int i = 0; i < vec[0].size() - 2; i++)
		{
			single_logic_path slp(*this);
			apply_function(slp.vec, i, &majority);
			slp.evolution_path += " majority " + to_string(i);
			slp.gates++; 
			if(slp.vec[0].size() >= 3 && slp.vec[0].size() <= max_width)
				result.push_back(slp);
		}
		
		return result; 
	}
	
	void print()
	{
		cout << evolution_path << "\n";
		for(int i = 0; i < vec.size(); i++)
			print_vec(vec[i]);
	}
	
	uint64_t Hash(const vector<bool>& vals, int d)
	{
		uint64_t res = 0ULL;	
		
		for(int i = 0; i < vals.size(); i++)
			if(vals[i])
				res |= (1ULL << i);
		
		return res << d; 
	}
	
	uint64_t Hash()
	{
		uint64_t hash = 0;
		
		for(int i = 0; i < 8; i ++)
			hash  |= Hash(vec[i], 8 * i);
		
		return hash; 
	}
	
	append(bool val, int idx, int& current)
	{
		if(val)
			current |= 1 << idx;
	}
	
	int count_gates(string evolution)
	{
		int count = 0; 
		
		vector<string> splited = split(evolution_path, ' ');
		for(int i = 0; i < splited.size(); i++)
		{
			if(splited[i] == "merge_and" || splited[i] == "majority" || splited[i] == "merge_or")
				count++;
		}
		
		return count; 
	}
	
	bool has_xor()
	{
		for(int i = 0; i < vec[0].size() - 1; i++)
		{
			static single_logic_path slp; 
			
			bool found = true; 
			for(int j = 0; j < vec.size(); j++)
			{
				if((int)(vec[j][i]) != ((slp.vec[j][0] + slp.vec[j][1]) % 2))
				{
					found = false; 
					break;
				}
			}
						
			if(found)
				return true;
		}
		
		return false; 
	}
	
	bool has_carrier()
	{
		for(int i = 0; i < vec[0].size() - 1; i++)
		{
			static single_logic_path slp; 
			
			bool found = true; 
			for(int j = 0; j < vec.size(); j++)
			{
				if(vec[j][i] != ((slp.vec[j][0] + slp.vec[j][1] + slp.vec[j][2]) > 1))
				{
					found = false; 
					break;
				}
			}
						
			if(found)
				return true;
		}
		
	}
	
	bool validate()
	{
		if(has_xor())
			//cout << "SUCCESS! Path:" << evolution_path << ", Ngates: " << gates << "\n";
			cout << "SUCCESS! Path:" << evolution_path << "\n";
			
		//static int optimal_gate_count = 100000; 
		//int gates = count_gates(evolution_path);
		
		//if(gates <= optimal_gate_count)
		{
			//optimal_gate_count = gates;
		}
	}
};


int main()
{
	vector<single_logic_path> path; 
	path.push_back(single_logic_path());
	map<uint64_t, int> hashs; 
	
	for(int counter = 0;;counter++)
	{
		cout << "Iter " << counter << " : " << path.size() << "\n"; 
		
		vector<single_logic_path> new_logic; 
		
		//#pragma omp parallel for 		
		for(int i = 0; i < path.size(); i++)
		{
			vector<single_logic_path> cur = path[i].evolve();
			
			for(int j = 0; j < cur.size();j++)
			{
				uint64_t hash = cur[j].Hash();
				
				if(hashs.find(hash) == hashs.end())
				{
					//#pragma omp critical
					{
						hashs[hash] = 1;
						new_logic.push_back(cur[j]);
					}
				}
				else 
					//#pragma omp atomic
					hashs[hash]++; 
					
				//#pragma omp critical
				//cur[j].validate();
				//cur[j].print();
			}	
		}
		
		path = new_logic;
	}
	
	int pp; 
	cin >> pp; 
}