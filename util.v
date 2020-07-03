module vsql

// 'name','name asc','name desc abc'
pub fn split_by_space(str string) (string, string) {
	args := str.trim_space().split(' ')
	match args.len {
		1 { return args[0], '' }
		2 { return args[0], args[1] }
		else { panic('string split to arg failed,it should be one or tow args,and seperate by space') }
	}
}

// 'name','name as n','name as n abc'
pub fn split_by_separator(str, separator string) (string, string) {
	args := str.trim_space().split(' ')
	match args.len {
		1 {
			return args[0], ''
		}
		3 {
			if args[1] == separator {
				return args[0], args[2]
			} else {
				panic('string split to arg failed,it should be one or tow args,and seperate by $separator')
			}
		}
		else {
			panic('string split to arg failed,it should be one or tow args,and seperate by $separator')
		}
	}
}
