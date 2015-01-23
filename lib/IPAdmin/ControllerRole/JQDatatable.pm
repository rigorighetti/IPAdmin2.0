package IPAdmin::ControllerRole::JQDatatable;

use Moose::Role;
use MooseX::MethodAttributes::Role;
use namespace::autoclean;

sub datatable_response : Private {
    my ($self, $c) = @_;

    my $rs = $c->stash->{'resultset'};
    my $search_options = $c->stash->{'resultset_search_opt'};
    my $col_names = $c->stash->{'col_names'};
    my $col_formatters = $c->stash->{'col_formatters'} || {};

    my $searchable_columns =
      $c->stash->{'col_searchable'} || [ @$col_names ];

    my $start = $c->request->param('iDisplayStart') || 0;
    my $size  = $c->request->param('iDisplayLength');
    my $echo  = $c->request->param('sEcho') || 0;

    my $search_attrs = {};
    my $search_filter = {};
    #my $search_filter = {select => @$col_names};
    my $search_filter_crit = [];

    # create filter (WHERE clause)
    my $search = $c->request->param('sSearch');
    if ($search) {
        my ($subnet,$host);
        if($c->stash->{'ip_search'} and $search =~ m/(\d+)\.(\d*)/g){
            #IP search!
            $subnet = $1; $host=$2;
	       if(defined $host and $host ne ''){
            	push @$search_filter_crit, {'-and' =>  [
                                                subnet => $subnet,
                                                host   => $host,
                                                ]}  ;
            }
	       else{
		      push @$search_filter_crit, { subnet => $subnet };
	        }
	    }
        elsif($search =~ m/=/g){
            push @$search_filter_crit, {state => $c->stash->{'search_type'}};
        }
        elsif($search =~ m/(\d{2}\/\d{2}\/\d{4})/g){
            push @$search_filter_crit, { date => IPAdmin::Utils::str_to_time($search) } ;            
        }
        else{
         foreach my $col (@$searchable_columns) {
            push @$search_filter_crit,  $col =>  { -like =>  "%$search%" } ;

            $c->log->debug("$col like $search");
         }
        }
        $search_filter = $search_filter_crit;
    }

    # add options if needed (JOIN, PREFETCH, ...)
    if ($search_options) {
        while ( my ($k, $v) = each(%$search_options) ) {
            $search_attrs->{$k} = $v;
        }
    }

    # number of rows after filtering (COUNT query)
    my $total_rows = $rs->search($search_filter, $search_attrs)->count();

    # paging (LIMIT clause)
    if ($size) {
        my $page = $size > 0 ? ($start+1) / $size : 1;
        $page == int($page) or $page = int($page) + 1;

        $search_attrs->{page} = $page;
        $search_attrs->{rows} = $size;
        $c->log->debug("page = $page size=$size");
    }

    # sorting (ORDER BY clause)
    my $n_sort_cols = $c->request->param('iSortingCols');
    if ( defined($n_sort_cols) && $n_sort_cols > 0) {
        my @cols;
        foreach my $i (0 .. $n_sort_cols - 1) {
            my $col_idx = $c->request->param("iSortCol_$i");
            my $col = $searchable_columns->[ $col_idx ];

            my $dir = 
              $c->request->param("sSortDir_$i") eq 'desc' ? '-desc' : '-asc';
            push @cols, { $dir => $col };
        }
        $search_attrs->{order_by} = \@cols;
    };
    # search!!!
    my @rows;

    my $search_rs =  $rs->search($search_filter, $search_attrs);
    while (my $item = $search_rs->next) {
        my @row;
        foreach my $name (@$col_names) {
            my $cell = '';
            # defaul accessor is preferred
            #$item->can($name) and $cell = $item->$name;
            my $f = $col_formatters->{$name};
            $f and $cell = $f->($c, $item);
            push @row, $cell;
        }
        push @rows, \@row;
    }

    my $data = {
        aaData => \@rows, 
        sEcho  => int($echo),
        iTotalRecords => $total_rows,
        iTotalDisplayRecords => $total_rows,
    };

    $c->stash('json_data' => $data);
    $c->forward('View::JSON');
}

1;
# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 4
# cperl-indent-parens-as-block: t
# End:
