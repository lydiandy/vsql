module vsql

// split the string by space, like this:'name'=>('name',''),'name asc'=>('name','asc'),'name desc abc'=> error
pub fn split_by_space(s string) (string, string) {
	args := s.trim_space().split(' ')
	match args.len {
		1 { return args[0], '' }
		2 { return args[0], args[1] }
		else { panic('table name or column name is wrong,it should be one or tow substring,and seperate by space') }
	}
}

// split the string by separator, like this:'name'=>('name',''),'name as n'=>('name','n'),'name as n abc'=> error
pub fn split_by_separator(s string, separator string) (string, string) {
	args := s.trim_space().split(' ')
	match args.len {
		1 {
			return args[0], ''
		}
		3 {
			if args[1] == separator {
				return args[0], args[2]
			} else {
				panic('table name or column name is wrong,it should be one or tow substring,and seperate by $separator')
			}
		}
		else {
			panic('table name or column name is wrong,it should be one or tow substring,and seperate by $separator')
		}
	}
}
