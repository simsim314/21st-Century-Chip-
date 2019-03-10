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
		vec.push_back(vector<bool>{true, true});
		vec.push_back(vector<bool>{true, false});
		vec.push_back(vector<bool>{false, true});
		vec.push_back(vector<bool>{false, false});
	}
	
	single_logic_path(const single_logic_path& other)
	{
		vec.push_back(other.vec[0]);
		vec.push_back(other.vec[1]);
		vec.push_back(other.vec[2]);
		vec.push_back(other.vec[3]);
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
		const int max_width = 8;
		
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
			if(slp.vec[0].size() >= 2 && slp.vec[0].size() <= max_width)
				result.push_back(slp);
		}
		
		for(int i = 0; i < vec[0].size() - 1; i++)
		{
			single_logic_path slp(*this);
			apply_function(slp.vec, i, &merge_or);
			slp.gates++; 
			slp.evolution_path += " merge_or " + to_string(i);
			if(slp.vec[0].size() >= 2 && slp.vec[0].size() <= max_width)
				result.push_back(slp);
		}
		
		for(int i = 0; i < vec[0].size() - 1; i++)
		{
			single_logic_path slp(*this);
			apply_function(slp.vec, i, &merge_and);
			slp.evolution_path += " merge_and " + to_string(i);
			slp.gates++; 
			if(slp.vec[0].size() >= 2 && slp.vec[0].size() <= max_width)
				result.push_back(slp);
		}
		
		for(int i = 0; i < vec[0].size() - 2; i++)
		{
			single_logic_path slp(*this);
			apply_function(slp.vec, i, &majority);
			slp.evolution_path += " majority " + to_string(i);
			slp.gates++; 
			if(slp.vec[0].size() >= 2 && slp.vec[0].size() <= max_width)
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
		return Hash(vec[0], 0) | Hash(vec[1], 16) | Hash(vec[2], 32) | Hash(vec[3], 48);
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
	
	bool validate(vector<int>& unique)
	{
		for(int i = 0; i < vec[0].size() - 1; i++)
		{
			//bool valid = vec[0][i] && vec[0][i + 1];
			//valid = valid && !vec[1][i] && vec[1][i + 1];
			//valid = valid && vec[2][i] && !vec[2][i + 1];
			//valid = valid && !vec[3][i] && !vec[3][i + 1];
			if(vec[0][i] == false && vec[1][i] == true && vec[2][i] == true && vec[3][i] == false)
			
			//if(vec[0][i] == true && vec[0][i + 1] == true && 
			//   vec[1][i] == false && vec[1][i + 1] == true &&
			//   vec[2][i] == true && vec[2][i + 1] == false &&
			//   vec[3][i] == false && vec[3][i + 1] == false)
			   {
					static int optimal_gate_count = 100000; 
					int gates = count_gates(evolution_path);
					
					if(gates <= optimal_gate_count)
					{
						cout << "SUCCESS! Path:" << evolution_path << ", Ngates: " << gates << "\n";
						optimal_gate_count = gates;
					}
					//cin >> i;
			   }
			
			{
				//cout << "SUCCESS! Path:" << evolution_path << "\n";
				//cin >> i;
			}
			
			int current = 0; 
			append(vec[0][i], 0, current);
			append(vec[0][i + 1], 1, current);
			append(vec[1][i], 2, current);
			append(vec[1][i + 1], 3, current);
			append(vec[2][i], 4, current);
			append(vec[2][i + 1], 5, current);
			append(vec[3][i], 6, current);
			append(vec[3][i + 1], 7, current);
			
			if(unique[current] == 0)
			{
				//cout << "Found : " << current << "  -   "; 
				unique[current] = 1;
				int k = current; 
				
				for(int j = 0; j < 8; j++)
				{
					//cout << k % 2 << ",";
					k /= 2; 
				}
				
				//cout << "\n";
			}
			
		}
	}
};


int main()
{
	vector<single_logic_path> path; 
	path.push_back(single_logic_path());
	map<uint64_t, int> hashs; 
	vector<int> vals(256, 0);
	
	for(int counter = 0;;counter++)
	{
		cout << "Iter " << counter << " : " << path.size(); 
		
		int total = 0; 
		
		for(int i = 0; i < 256; i++)
			if(vals[i] > 0)
				total++;
			
		cout << "  Total:" << total << "\n";
		
		vector<single_logic_path> new_logic; 
		
		#pragma omp parallel for 		
		for(int i = 0; i < path.size(); i++)
		{
			vector<single_logic_path> cur = path[i].evolve();
			
			for(int j = 0; j < cur.size();j++)
			{
				uint64_t hash = cur[j].Hash();
				
				if(hashs.find(hash) == hashs.end())
				{
					#pragma omp critical
					{
						hashs[hash] = 1;
						new_logic.push_back(cur[j]);
					}
				}
				else 
					#pragma omp atomic
					hashs[hash]++; 
					
				#pragma omp critical
				cur[j].validate(vals);
				//cur[j].print();
			}	
		}
		
		path = new_logic;
	}
	
	int pp; 
	cin >> pp; 
}