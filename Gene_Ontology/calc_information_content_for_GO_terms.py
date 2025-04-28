from collections import defaultdict
import sys
import os
import math

#====================================================================#

# define a function to record the children of each GO term in the GO hierarchy:

def read_go_children(input_go_obo_file):
    """record the children of each GO term in the GO hierarchy"""

    # first read in the input GO file, and make a list of all the GO terms, and the
    # terms below them in the GO hierarchy:
    # eg.
    # [Term]
    # id: GO:0004835
    children = defaultdict(list) # children of a particular GO term, in the hierarchy 
    take = 0

    fileObj = open(input_go_obo_file, "r")
    for line in fileObj:
        line = line.rstrip()
        temp = line.split()
        if len(temp) == 1:
           if temp[0] == '[Term]':
               take = 1
        elif len(temp) >= 2 and take == 1:
            if temp[0] == 'id:':
                go = temp[1]
                if go == 'GO:0009790':  
                    go = 'GO:0009795' # an alt_id in the obo file 
                elif go == 'GO:0006974':
                    go = 'GO:0034984'
            elif temp[0] == 'is_a:': # eg. is_a: GO:0048308 ! organelle inheritance
                parent = temp[1]
                if parent == 'GO:0009790':
                    parent = 'GO:0009795' # an alt_id in the obo file 
                elif parent == 'GO:0006974':
                    parent = 'GO:0034984'
                children[parent].append(go) # record that a child of 'parent' is term 'go'
        elif len(temp) == 0:
            take = 0
    fileObj.close()

    return children

#====================================================================#

# define a function to find all descendants of a GO term in the GO hierarchy:

def find_all_descendants(input_go_term, children):
    """find all the descendants of a GO term in the GO hierarchy
    >> find_all_descendants('GO1', {'GO1': ['GO2', 'GO3'], 'GO2': ['GO4']})
    ['GO1', 'GO2', 'GO3', 'GO4']
    """

    descendants = set()
    queue = []
    queue.append(input_go_term)
    while queue:
        node = queue.pop(0)
        if node in children and node not in descendants: # don't visit a second time
            node_children = children[node]
            queue.extend(node_children)
        descendants.add(node)

    return descendants  

#====================================================================#

# store the the count of annotations seen for each GO term:

def store_counts_for_GO_terms(input_go_terms_file):

    # make a dictionary to contain the count of annotations seen for a particular GO term.
    gocnt = defaultdict()
    # GO:0004174 2
    # GO:0070461 1
    # GO:0035371 2
    # GO:0000381 1
    # GO:0022414 2
    # GO:0032436 1
    # GO:0010608 7
    # ...
    fileObj = open(input_go_terms_file, "r")
    for line in fileObj:
        line = line.rstrip()
        temp = line.split()
        term = temp[0]
        cnt = int(temp[1])
        if term == 'GO:0009790':
            term = 'GO:0009795' # an alt_id in the obo file 
        elif term == 'GO:0006974':
            term = 'GO:0034984'
        # store the count of annotations for the GO term:
        if term not in gocnt:
            gocnt[term] = cnt
        else:
            gocnt[term] = gocnt[term] + cnt #  we can get different alternative ids on different lines eg. GO:0009795, GO:0009790
    fileObj.close()

    return gocnt

#====================================================================#

# write an output file with all GO terms in the obo file, and their information contents:

def write_output_file(icdict, output_file):

    outputfileObj = open(output_file, "w")
    for term in icdict.keys():
        ic = icdict[term]
        output_line = "%s %f\n" % (term, ic)
        outputfileObj.write(output_line)
    outputfileObj.close()

    return

#====================================================================#
# read in the file with input GO terms of interest, and calculate their information contents:

def calculate_information_contents_of_GO_terms(input_go_terms_file, children):

    # make a dictionary to store the information contents for terms:
    icdict = defaultdict()

    # first store the the count of annotations seen for each GO term:
    gocnt = store_counts_for_GO_terms(input_go_terms_file)
    terms = gocnt.keys()

    # for each of the three ontologies (biological process, molecular function, cellular component),
    # calculate the information content of GO terms:
    for x in range(0, 3):
        if x == 0:
            root = 'GO:0005575' # cellular component
        elif x == 1:
            root = 'GO:0008150' # biological process
        elif x == 2:
            root = 'GO:0003674' # molecular function
        # find all the descendants of the root term:
        root_descendants = find_all_descendants(root, children)

        # calculate the frequency for the root term:
        root_freq = calculate_freq(root, root_descendants, gocnt)

        # calculate the information content for all the terms in this ontology (whether or not we have annotations for them):
        for term in root_descendants:  
            # find the descendants of this term:
            term_descendants = find_all_descendants(term, children)
            # calculate the frequency for this term:
            term_freq = calculate_freq(term, term_descendants, gocnt)
            # estimate the probability of this term:
            term_prob = (term_freq + 1) / (root_freq + 1) # add a pseudocount of 1 so we can always calculate the IC, even for terms we don't have annotations for
            # calculate the information content of this term:
            term_ic = -math.log(term_prob) # natural logarithm
            assert(term not in icdict)
            icdict[term] = term_ic

    return icdict

#====================================================================#

# calculate the frequency for a term:

def calculate_freq(term, descendants, gocnt):

    freq = 0
    if term in gocnt: 
        freq = freq + gocnt[term] 
    for descendant in descendants:
        if descendant in gocnt:
            freq = freq + gocnt[descendant]

    return freq

#====================================================================#

def main():
    # check the command-line arguments:
    if len(sys.argv) != 4 or os.path.exists(sys.argv[1]) == False or os.path.exists(sys.argv[2]) == False:
        print("Usage: %s input_go_obo_file input_go_terms_file output_file" % sys.argv[0]) 
        sys.exit(1)
    input_go_obo_file = sys.argv[1] # the input gene ontology file eg. gene_ontology.WS238.obo
    input_go_terms_file = sys.argv[2] # file with the input GO terms of interest, that we want to calculate the information content for
    output_file = sys.argv[3]

    # read in the children of each GO term in the GO hierachy:
    children = read_go_children(input_go_obo_file)

    # read in the file with input GO terms of interest, and calculate their information contents:
    icdict = calculate_information_contents_of_GO_terms(input_go_terms_file, children)

    # write an output file with all GO terms of interest in the obo file, and their information contents:
    write_output_file(icdict, output_file)

    print("FINISHED\n")
    
#====================================================================#

if __name__=="__main__":
    main()

#====================================================================#
